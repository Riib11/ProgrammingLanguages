def tolist(x):
    if isinstance(x, TreeNode):
        return list(map(tolist,x.children))
    else:
        return x

class TreeNode:
    def __init__(self, parent):
        self.parent = parent
        if parent: parent.add(self)
        self.children = []

    def add(self, x): self.children.append(x)

    def tostring(self):
        return str(self.children)
    __str__ = tostring; __repr__ = tostring