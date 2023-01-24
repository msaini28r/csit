# -*- coding: utf-8 -*-

"""CSIT report documentation build configuration file

This file is execfile()d with the current directory set to its
containing dir.

Note that not all possible configuration values are present in this
autogenerated file.

All configuration values have a default; values that are commented out
serve to show the default.

If extensions (or modules to document with autodoc) are in another directory,
add these directories to sys.path here. If the directory is relative to the
documentation root, use os.path.abspath to make it absolute, like shown here.
"""


import os
import sys
import sphinx_rtd_theme

sys.path.insert(0, os.path.abspath('.'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinxcontrib.programoutput',
    'sphinx.ext.ifconfig',
    'sphinx_rtd_theme'
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source file names.
# You can specify multiple suffix as a list of string:
#
source_suffix = ['.rst', '.md']

# The master toctree document.
master_doc = 'index'

# General information about the project.
report_week = '4'
project = 'FD.io CSIT-2302.{week}'.format(week=report_week)
copyright = '2023, FD.io'
author = 'FD.io CSIT'

# The version info for the project yo're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
# version = ''
# The full version, including alpha/beta/rc tags.
# release = ''

rst_epilog = """
.. |release-1| replace:: {prev_release}
.. |srelease| replace:: {srelease}
.. |csit-release| replace:: CSIT-{csitrelease}
.. |csit-release-1| replace:: CSIT-{csit_prev_release}
.. |vpp-release| replace:: VPP-{vpprelease} release
.. |vpp-release-1| replace:: VPP-{vpp_prev_release} release
.. |dpdk-release| replace:: DPDK-{dpdkrelease}
.. |dpdk-release-1| replace:: DPDK-{dpdk_prev_release}
.. |trex-release| replace:: TRex {trex_version}

.. _pdf version of this report: https://s3-docs.fd.io/csit/{release}/report/_static/archive/csit_{release}.{report_week}.pdf
.. _tag documentation rst file: https://git.fd.io/csit/tree/docs/tag_documentation.rst?h={release}
.. _TRex driver: https://git.fd.io/csit/tree/GPL/tools/trex/trex_stl_profile.py?h={release}
.. _CSIT Performance Tests Documentation: https://s3-docs.fd.io/csit/{release}/docs/index.html
.. _VPP test framework documentation: https://docs.fd.io/vpp/{vpprelease}/vpp_make_test/html/
.. _FD.io CSIT testbeds - Atom Snowridge: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_snr_hw_bios_cfg.md?h={release}
.. _FD.io CSIT testbeds - EPYC Zen2: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_zn2_hw_bios_cfg.md?h={release}
.. _FD.io CSIT testbeds - Xeon Ice Lake: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_icx_hw_bios_cfg.md?h={release}
.. _FD.io CSIT testbeds - Xeon Cascade Lake: https://git.fd.io/csit/tree/docs/lab/testbeds_sm_clx_hw_bios_cfg.md?h={release}
.. _Ansible inventory - hosts: https://git.fd.io/csit/tree/fdio.infra.ansible/inventories/lf_inventory/host_vars?h={release}
.. _build logs from FD.io trex performance job 1n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-iterative-{srelease}-1n-aws
.. _build logs from FD.io trex performance job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-iterative-{srelease}-2n-icx
.. _build logs from FD.io dpdk performance job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-icx
.. _build logs from FD.io dpdk performance job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-icx
.. _build logs from FD.io dpdk performance job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-clx
.. _build logs from FD.io dpdk performance job 3n-alt: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-alt
.. _build logs from FD.io dpdk performance job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-3n-tsh
.. _build logs from FD.io dpdk performance job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-tx2
.. _build logs from FD.io dpdk performance job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-iterative-{srelease}-2n-zn2
.. _build logs from FD.io vpp performance job 3n-alt: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-alt
.. _build logs from FD.io vpp performance job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-tsh
.. _build logs from FD.io vpp performance job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-tx2
.. _build logs from FD.io vpp performance job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-clx
.. _build logs from FD.io vpp performance job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-icx
.. _build logs from FD.io vpp performance job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-3n-icx
.. _build logs from FD.io vpp performance job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-zn2
.. _build logs from FD.io vpp performance job 2n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-iterative-{srelease}-2n-aws
.. _build logs from FD.io dpdk coverage job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-icx
.. _build logs from FD.io dpdk coverage job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-icx
.. _build logs from FD.io dpdk coverage job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-clx
.. _build logs from FD.io dpdk coverage job 3n-alt: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-alt
.. _build logs from FD.io dpdk coverage job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-3n-tsh
.. _build logs from FD.io dpdk coverage job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-tx2
.. _build logs from FD.io dpdk coverage job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-dpdk-perf-report-coverage-{srelease}-2n-zn2
.. _build logs from FD.io trex coverage job 1n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-coverage-{srelease}-1n-aws
.. _build logs from FD.io trex coverage job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-trex-perf-report-coverage-{srelease}-2n-icx
.. _build logs from FD.io vpp coverage job 3n-alt: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-alt
.. _build logs from FD.io vpp coverage job 3n-tsh: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-tsh
.. _build logs from FD.io vpp coverage job 2n-tx2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-tx2
.. _build logs from FD.io vpp coverage job 2n-clx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-clx
.. _build logs from FD.io vpp coverage job 2n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-icx
.. _build logs from FD.io vpp coverage job 3n-icx: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-3n-icx
.. _build logs from FD.io vpp coverage job 2n-zn2: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-zn2
.. _build logs from FD.io vpp coverage job 2n-aws: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-perf-report-coverage-{srelease}-2n-aws
.. _build logs from FD.io vpp device jobs using Ubuntu: https://s3-logs.fd.io/vex-yul-rot-jenkins-1/csit-vpp-device-{srelease}-ubuntu2004-1n-skx
.. _FD.io VPP compile job: https://jenkins.fd.io/view/vpp/job/vpp-merge-{srelease}-ubuntu2004-x86_64/
.. _CSIT Testbed Setup: https://git.fd.io/csit/tree/fdio.infra.ansible?h={release}
.. _VPP startup.conf: https://git.fd.io/vpp/tree/src/vpp/conf/startup.conf?h=stable/{srelease}&id={vpp_release_commit_id}
""".format(release='rls2302',
           report_week=report_week,
           prev_release='rls2210',
           srelease='2302',
           csitrelease='2302',
           csit_prev_release='2210',
           vpprelease='23.020',
           vpp_prev_release='22.10',
           dpdkrelease='22.07',
           dpdk_prev_release='22.03',
           sdpdkrelease='22.07',
           trex_version='v3.00',
           vpp_release_commit_id='07e0c05e698cf5ffd1e2d2de0296d1907519dc3d')

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This patterns also effect to html_static_path and html_extra_path
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
html_theme_options = {
    'analytics_id': '',
    'analytics_anonymize_ip': False,
    'logo_only': False,
    'display_version': True,
    'prev_next_buttons_location': 'bottom',
    'style_external_links': False,
    'vcs_pageview_mode': '',
    'style_nav_header_background': '#2980b9',
    # Toc options
    'collapse_navigation': True,
    'sticky_navigation': True,
    'navigation_depth': 4,
    'includehidden': True,
    'titles_only': False
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".

html_static_path = ['_tmp/src/_static']

html_context = {
    'css_files': [
        '_static/css/theme.css',
        '_static/css/badge_only.css',
        # overrides for wide tables in RTD theme
        '_static/theme_overrides.css',
    ]
}

# If false, no module index is generated.
html_domain_indices = True

# If false, no index is generated.
html_use_index = True

# If true, the index is split into individual pages for each letter.
html_split_index = False

# -- Options for LaTeX output ---------------------------------------------

latex_engine = 'pdflatex'

latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    #
    'papersize': 'a4paper',

    # The font size ('10pt', '11pt' or '12pt').
    #
    #'pointsize': '10pt',

    # Additional stuff for the LaTeX preamble.
    #
    'preamble': r'''
     \usepackage{pdfpages}
     \usepackage{svg}
     \usepackage{charter}
     \usepackage[defaultsans]{lato}
     \usepackage{inconsolata}
     \usepackage{csvsimple}
     \usepackage{longtable}
     \usepackage{booktabs}
    ''',

    # Latex figure (float) alignment
    #
    'figure_align': 'H',

    # Latex font setup
    #
    'fontpkg': r'''
     \renewcommand{\familydefault}{\sfdefault}
    ''',

    # Latex other setup
    #
    'extraclassoptions': 'openany',
    'sphinxsetup': r'''
     TitleColor={RGB}{225,38,40},
     InnerLinkColor={RGB}{62,62,63},
     OuterLinkColor={RGB}{225,38,40},
     shadowsep=0pt,
     shadowsize=0pt,
     shadowrule=0pt
    '''
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'csit.tex', 'CSIT REPORT', '', 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#
# latex_logo = 'fdio.pdf'

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#
# latex_use_parts = True

# If true, show page references after internal links.
#
latex_show_pagerefs = True

# If true, show URL addresses after external links.
#
latex_show_urls = 'footnote'

# Documents to append as an appendix to all manuals.
#
# latex_appendices = []

# It false, will not define \strong, \code, 	itleref, \crossref ... but only
# \sphinxstrong, ..., \sphinxtitleref, ... To help avoid clash with user added
# packages.
#
# latex_keep_old_macro_names = True

# If false, no module index is generated.
#
# latex_domain_indices = True
