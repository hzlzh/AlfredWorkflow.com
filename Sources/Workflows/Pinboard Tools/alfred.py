#author: Peter Okma
import xml.etree.ElementTree as et


class Feedback():
    """Feeback used by Alfred Script Filter

    Usage:
        fb = Feedback()
        fb.add_item('Hello', 'World')
        fb.add_item('Foo', 'Bar')
        print fb

    """

    def __init__(self):
        self.feedback = et.Element('items')

    def __repr__(self):
        """XML representation used by Alfred

        Returns:
            XML string
        """
        return et.tostring(self.feedback)

    def add_item(self, title, subtitle="", arg="", icon="icon.png"):
        """
        Add item to alfred Feedback

        Args:
            title(str): the title displayed by Alfred
        Keyword Args:
            arg(str):      the value returned by alfred when item is selected
            subtitle(str): the subtitle displayed by Alfred
            icon(str):     filename of icon that Alfred will display
        """
        item = et.SubElement(self.feedback, 'item',
            uid=str(len(self.feedback)), arg=arg)
        _title = et.SubElement(item, 'title')
        _title.text = title
        _sub = et.SubElement(item, 'subtitle')
        _sub.text = subtitle
        _icon = et.SubElement(item, 'icon')
        _icon.text = icon
