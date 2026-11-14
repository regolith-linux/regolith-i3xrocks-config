"""Stand-in for i3ipc: the focused window's title contains line breaks."""


class Event:
    pass


class _Window:
    name = "first line\nsecond line\r\nthird"
    window_instance = "xterm"


class _Tree:
    def find_focused(self):
        return _Window()


class Connection:
    def get_tree(self):
        return _Tree()
