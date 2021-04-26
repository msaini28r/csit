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

"""CSIT Presentation and Analytics Layer.
"""

import sys
import argparse
import logging

from pal_errors import PresentationError
from specification_parser import Specification
from environment import Environment, clean_environment
from static_content import prepare_static_content
from input_data_parser import InputData
from generator_tables import generate_tables
from generator_plots import generate_plots
from generator_files import generate_files
from generator_report import generate_report
from generator_cpta import generate_cpta
from generator_alerts import Alerting, AlertingError


OUTPUTS = (u"none", u"report", u"trending", u"convert_to_json")


def parse_args():
    """Parse arguments from cmd line.

    :returns: Parsed arguments.
    :rtype: ArgumentParser
    """

    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        u"-s", u"--specification",
        required=True,
        type=str,
        help=u"Specification YAML file."
    )
    parser.add_argument(
        u"-r", u"--release",
        default=u"master",
        type=str,
        help=u"Release string of the product."
    )
    parser.add_argument(
        u"-w", u"--week",
        default=u"1",
        type=str,
        help=u"Calendar week when the report is published."
    )
    parser.add_argument(
        u"-l", u"--logging",
        choices=[
            u"NOTSET", u"DEBUG", u"INFO", u"WARNING", u"ERROR", u"CRITICAL"
        ],
        default=u"ERROR",
        help=u"Logging level."
    )
    parser.add_argument(
        u"-f", u"--force",
        action=u"store_true",
        help=u"Force removing the old build(s) if present."
    )
    parser.add_argument(
        u"-o", u"--print-all-oper-data",
        action=u"store_true",
        help=u"Print all operational data to console. Be careful, the output "
             u"can be really long."
    )
    parser.add_argument(
        u"-i", u"--input-file",
        type=str,
        default=u"",
        help=u"XML file generated by RobotFramework which will be processed "
             u"instead of downloading the data from Nexus and/or Jenkins. In "
             u"this case, the section 'input' in the specification file is "
             u"ignored."
    )
    parser.add_argument(
        u"-d", u"--input-directory",
        type=str,
        default=u"",
        help=u"Directory with XML file(s) generated by RobotFramework or with "
             u"sub-directories with XML file(s) which will be processed "
             u"instead of downloading the data from Nexus and/or Jenkins. In "
             u"this case, the section 'input' in the specification file is "
             u"ignored."
    )

    return parser.parse_args()


def main():
    """Main function."""

    log_levels = {
        u"NOTSET": logging.NOTSET,
        u"DEBUG": logging.DEBUG,
        u"INFO": logging.INFO,
        u"WARNING": logging.WARNING,
        u"ERROR": logging.ERROR,
        u"CRITICAL": logging.CRITICAL
    }

    args = parse_args()
    logging.basicConfig(
        format=u"%(asctime)s: %(levelname)s: %(message)s",
        datefmt=u"%Y/%m/%d %H:%M:%S",
        level=log_levels[args.logging]
    )

    logging.info(u"Application started.")

    try:
        spec = Specification(args.specification)
        spec.read_specification()
    except PresentationError as err:
        logging.critical(u"Finished with error.")
        return 1

    if spec.output[u"output"] not in OUTPUTS:
        logging.critical(
            f"The output {spec.output[u'output']} is not supported."
        )
        return 1

    return_code = 1
    try:
        env = Environment(spec.environment, args.force)
        env.set_environment()

        prepare_static_content(spec)

        data = InputData(spec)
        if args.input_file:
            data.process_local_file(args.input_file)
        elif args.input_directory:
            data.process_local_directory(args.input_directory)
        else:
            data.download_and_parse_data(repeat=1)

        if args.print_all_oper_data:
            data.print_all_oper_data()

        generate_tables(spec, data)
        generate_plots(spec, data)
        generate_files(spec, data)

        if spec.output[u"output"] == u"report":
            generate_report(args.release, spec, args.week)
        elif spec.output[u"output"] == u"trending":
            sys.stdout.write(generate_cpta(spec, data))
            try:
                alert = Alerting(spec)
                alert.generate_alerts()
            except AlertingError as err:
                logging.warning(repr(err))
        else:
            logging.info("No output will be generated.")

        logging.info(u"Successfully finished.")
        return_code = 0

    except AlertingError as err:
        logging.critical(f"Finished with an alerting error.\n{repr(err)}")
    except PresentationError as err:
        logging.critical(f"Finished with a PAL error.\n{str(err)}")
    except (KeyError, ValueError) as err:
        logging.critical(f"Finished with an error.\n{repr(err)}")
    finally:
        if spec is not None:
            clean_environment(spec.environment)
    return return_code


if __name__ == u"__main__":
    sys.exit(main())
