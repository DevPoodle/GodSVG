## An <ellipse/> tag.
class_name TagEllipse extends Tag

const name = "ellipse"
const possible_conversions = ["circle", "rect", "path"]
const icon = preload("res://visual/icons/tag/ellipse.svg")

const known_shape_attributes = ["cx", "cy", "rx", "ry"]
const known_inheritable_attributes = ["transform", "opacity", "fill", "fill-opacity",
		"stroke", "stroke-opacity", "stroke-width"]

func _init(pos := Vector2.ZERO) -> void:
	attributes = {
		"transform": AttributeTransform.new(),
		"cx": AttributeNumeric.new(AttributeNumeric.Mode.FLOAT, "0"),
		"cy": AttributeNumeric.new(AttributeNumeric.Mode.FLOAT, "0"),
		"rx": AttributeNumeric.new(AttributeNumeric.Mode.UFLOAT, "0", "1"),
		"ry": AttributeNumeric.new(AttributeNumeric.Mode.UFLOAT, "0", "1"),
		"opacity": AttributeNumeric.new(AttributeNumeric.Mode.NFLOAT, "1"),
		"fill": AttributeColor.new("black"),
		"fill-opacity": AttributeNumeric.new(AttributeNumeric.Mode.NFLOAT, "1"),
		"stroke": AttributeColor.new("none"),
		"stroke-opacity": AttributeNumeric.new(AttributeNumeric.Mode.NFLOAT, "1"),
		"stroke-width": AttributeNumeric.new(AttributeNumeric.Mode.UFLOAT, "1"),
	}
	attributes.cx.set_num(pos.x)
	attributes.cy.set_num(pos.y)
	super()


func can_replace(new_tag: String) -> bool:
	if new_tag == "circle":
		return attributes.rx.get_num() == attributes.ry.get_num()
	else:
		return new_tag in ["rect", "path"]

func get_replacement(new_tag: String) -> Tag:
	if not can_replace(new_tag):
		return null
	
	var tag: Tag
	var retained_attributes: Array[String] = []
	match new_tag:
		"circle":
			tag = TagCircle.new()
			retained_attributes = ["cx", "cy", "transform", "opacity", "fill",
					"fill-opacity", "stroke", "stroke-opacity", "stroke-width"]
			tag.attributes.r.set_num(attributes.rx.get_num(), Attribute.SyncMode.SILENT)
		"rect":
			tag = TagRect.new()
			retained_attributes = ["rx", "ry", "transform", "opacity", "fill",
					"fill-opacity", "stroke", "stroke-opacity", "stroke-width"]
			tag.attributes.x.set_num(attributes.cx.get_num() - attributes.rx.get_num(),
					Attribute.SyncMode.SILENT)
			tag.attributes.y.set_num(attributes.cy.get_num() - attributes.ry.get_num(),
					Attribute.SyncMode.SILENT)
			tag.attributes.width.set_num(attributes.rx.get_num() * 2,
					Attribute.SyncMode.SILENT)
			tag.attributes.height.set_num(attributes.ry.get_num() * 2,
					Attribute.SyncMode.SILENT)
		"path":
			tag = TagPath.new()
			retained_attributes = ["transform", "opacity", "fill",
					"fill-opacity", "stroke", "stroke-opacity", "stroke-width"]
			var commands: Array[PathCommand] = []
			commands.append(PathCommand.MoveCommand.new(attributes.cx.get_num(),
					attributes.cy.get_num() - attributes.ry.get_num(), true))
			commands.append(PathCommand.EllipticalArcCommand.new(attributes.rx.get_num(),
					attributes.ry.get_num(), 0, 0, 0, 0, attributes.ry.get_num() * 2, true))
			commands.append(PathCommand.EllipticalArcCommand.new(attributes.rx.get_num(),
					attributes.ry.get_num(), 0, 0, 0, 0, -attributes.ry.get_num() * 2, true))
			commands.append(PathCommand.CloseCommand.new(true))
			tag.attributes.d.set_commands(commands, Attribute.SyncMode.SILENT)
	for k in retained_attributes:
		tag.attributes[k].set_value(attributes[k].get_value(), Attribute.SyncMode.SILENT)
	
	return tag
