# Copyright (c) 2021 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module holding AvgStdevStats class."""

import math


class AvgStdevStats:
    """Class for statistics which include average and stdev of a group.

    Contrary to other stats types, adding values to the group
    is computationally light without any caching.

    Instances are only statistics, the data itself is stored elsewhere.
    """

    def __init__(self, size=0, avg=0.0, stdev=0.0):
        """Construct the stats object by storing the values needed.

        Each value has to be numeric.
        The values are not sanitized depending on size, wrong initialization
        can cause delayed math errors.

        :param size: Number of values participating in this group.
        :param avg: Population average of the participating sample values.
        :param stdev: Population standard deviation of the sample values.
        :type size: int
        :type avg: float
        :type stdev: float
        """
        self.size = size
        self.avg = avg
        self.stdev = stdev

    def __str__(self):
        """Return string with human readable description of the group.

        :returns: Readable description.
        :rtype: str
        """
        return f"size={self.size} avg={self.avg} stdev={self.stdev}"

    def __repr__(self):
        """Return string executable as Python constructor call.

        :returns: Executable constructor call.
        :rtype: str
        """
        return (
            f"AvgStdevStats(size={self.size!r},avg={self.avg!r}"
            f",stdev={self.stdev!r})"
        )

    @classmethod
    def for_runs(cls, runs):
        """Return new stats instance describing the sequence of runs.

        If you want to append data to existing stats object,
        you can simply use the stats object as the first run.

        Instead of a verb, "for" is used to start this method name,
        to signify the result contains less information than the input data.

        Here, Run is a hypothetical abstract class, an union of float and cls.
        Defining that as a real abstract class in Python 2 is too much hassle.

        :param runs: Sequence of data to describe by the new metadata.
        :type runs: Iterable[Union[float, cls]]
        :returns: The new stats instance.
        :rtype: cls
        """
        # Using Welford method to be more resistant to rounding errors.
        # Adapted from code for sample standard deviation at:
        # https://www.johndcook.com/blog/standard_deviation/
        # The logic of plus operator is taken from
        # https://www.johndcook.com/blog/skewness_kurtosis/
        total_size = 0
        total_avg = 0.0
        moment_2 = 0.0
        for run in runs:
            if isinstance(run, (float, int)):
                run_size = 1
                run_avg = run
                run_stdev = 0.0
            else:
                run_size = run.size
                run_avg = run.avg
                run_stdev = run.stdev
            old_total_size = total_size
            delta = run_avg - total_avg
            total_size += run_size
            total_avg += delta * run_size / total_size
            moment_2 += run_stdev * run_stdev * run_size
            moment_2 += delta * delta * old_total_size * run_size / total_size
        if total_size < 1:
            # Avoid division by zero.
            return cls(size=0)
        # TODO: Is it worth tracking moment_2 instead, and compute and cache
        # stdev on demand, just to possibly save some sqrt calls?
        total_stdev = math.sqrt(moment_2 / total_size)
        ret_obj = cls(size=total_size, avg=total_avg, stdev=total_stdev)
        return ret_obj
