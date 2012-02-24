#!/usr/bin/env python
"""

    Build the arguments for the command-line invocation of a Clang plugin.

    It's really annoying to have to say `-Xclang` in front of *every single
    argument related to the plugin*. Furthermore, we have to say
    `-plugin-arg-my-plugin` in front of each argument to be passed to be
    plugin (and yes, the `-plugin-arg-my-plugin` itself needs to have a
    '-Xclang' in front of it). Automate or die.

"""

import sys

class InvocationBuilder(object):

    def __init__(self, so_name, plugin_name, args):
        self._accum = []
        self._so_name = so_name
        self._plugin_name = plugin_name

        self.cc1_arg('-load')
        self.cc1_arg(so_name)
        self.cc1_arg('-plugin')
        self.cc1_arg(plugin_name)

        for arg in args:
            self.plugin_arg(arg)

    def accum(self, s):
        self._accum.append(s)

    def cc1_arg(self, arg):
        """Each cc1 arg must have `-Xclang` before it."""
        self.accum('-Xclang')
        self.accum(arg)

    def plugin_arg(self, arg):
        """Each plugin arg must have `-plugin-arg-plugin-name` before it
        and each of these is a cc1 arg.
        """
        self.cc1_arg('-plugin-arg-' + self._plugin_name)
        self.cc1_arg(arg)

    def __str__(self):
        return ' '.join(self._accum)

def usage():
    """Usage: invocation_builder.py ./MyPlugin.so my-plugin --arg1=foo -bar
    """
    print usage.__doc__

def main():
    if not len(sys.argv) >= 3:
        sys.exit(usage())
    so_name, plugin_name = sys.argv[1:3]
    args = sys.argv[3:]

    print str(InvocationBuilder(so_name, plugin_name, args))

if __name__ == '__main__':
    main()
