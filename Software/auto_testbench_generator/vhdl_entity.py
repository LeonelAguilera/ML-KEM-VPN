import json


class Generic:
    name = ""
    type = ""

    def __repr__(self):
        return f"Generic(name = {self.name!r}, type = {self.type!r}"


class Port:
    name = ""
    direction = ""
    type = ""

    def __repr__(self):
        return f"Generic(name = {self.name!r}, direction = {self.direction!r}, type = {self.type!r}"


class Entity:
    generics = []
    ports = []

    def __repr__(self):
        data = {
            "generics": self.generics,
            "ports": self.ports,
        }
        return json.dumps(
            data,
            default=lambda o: o.__dict__,
            indent=2,
            sort_keys=True
        )
