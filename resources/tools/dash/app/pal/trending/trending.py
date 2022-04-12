# Copyright (c) 2022 Cisco and/or its affiliates.
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

"""Instantiate the Trending Dash applocation.
"""
import dash
import dash_bootstrap_components as dbc

from .layout import Layout


def init_trending(server):
    """Create a Plotly Dash dashboard.

    :param server: Flask server.
    :type server: Flask
    :returns: Dash app server.
    :rtype: Dash
    """

    dash_app = dash.Dash(
        server=server,
        routes_pathname_prefix=u"/trending/",
        external_stylesheets=[dbc.themes.BOOTSTRAP],
    )

    # Custom HTML layout
    layout = Layout(
        app=dash_app,
        html_layout_file="pal/templates/trending_layout.jinja2",
        spec_file="pal/trending/spec_test_selection.yaml",
        graph_layout_file="pal/trending/layout.yaml",
        data_spec_file="pal/data/data.yaml"
    )
    dash_app.index_string = layout.html_layout
    dash_app.layout = layout.add_content()

    return dash_app.server
