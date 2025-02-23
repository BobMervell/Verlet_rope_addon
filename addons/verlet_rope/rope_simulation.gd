@tool
extends Node3D
class_name Rope3D

## A node used to simulate a rope physics system with adjustable parameters.
## The node also supports control over the simulation's precision and performance.
## [br][b]Note:[/b]
## Use a dedicated wind_processor to integrate wind effects. 


class RopePoint:
	var current_position:Vector3
	var previous_position:= Vector3.ZERO
	var gravity_strength:Vector3
	var speed_damping:float
	var locked:bool = false
	var additional_forces:= Vector3.ZERO
	var wind_force:= Vector3.ZERO
	
	func update_wind_force(new_wind:Vector3,wind_impact:float) -> void:
		wind_force = new_wind * wind_impact

	func update_point(delta:float) -> void:
		if not locked:
			var old_pos:Vector3 = current_position
			current_position += (current_position - previous_position) * (1-(0.1*speed_damping)) # keep speed
			current_position += gravity_strength * delta**2 #add gravity
			current_position += wind_force * delta**2 # add wind
			current_position += additional_forces * delta**2 #add other
			previous_position = old_pos

class RopeLink:
	var point_A:RopePoint
	var point_B:RopePoint
	var length:float
	var stiffness:float
	const root_approxi=0.45
	const approxi = 0.2

	func update_link() -> void:
		var dir:Vector3 = point_B.current_position - point_A.current_position
		var difference: float = dir.length() - length
		dir = dir.normalized()
		if point_A.locked:
			point_B.current_position -= dir * difference * stiffness
		elif point_B.locked:
			point_A.current_position += dir * difference * stiffness
		else:
			point_A.current_position += dir * difference *.5 * stiffness
			point_B.current_position -= dir * difference * .5 * stiffness

## Controls the stiffness of the rope. Lower values make the rope more elastic.
@export_range(0,1) var rope_stiffness:float = 1
## Controls the impact and direction of gravity.
@export var gravity_strength:= Vector3(0,-20,0)
## Controls the speed damping, simulating air resistance.
@export_range(0,10) var speed_damping:float = .2 
## Controls the number of points simulating the rope. 
## [br][b]Note:[/b]
## This parameter [b] significantly impacts performance.[/b]
@export_range(0,50) var nbr_point:int = 20
## Controls the theoretical length of the rope, based on the distance between the start and end points.
## The actual length is influenced by rope stiffness and gravity strength.
@export_range(0,2,.01,"or_greater") var rope_length_ratio:float = .7
## Defines the starting position of the rope, which is fixed.
@export var start_pos:= Vector3.ONE
## Defines the ending position of the rope, which is fixed.
@export var end_pos:= Vector3.ZERO

## Optional node for applying wind impact to the rope. 
##[br][b]Note:[/b]
## The node [b] must include[/b] the following function:
## [br][code]func get_wind_strength(position: Vector3) -> Vector3: [/code]
## This function returns the wind strength and direction at a given world position.
@export var wind_processor:Node
## Controls the impact of the wind.
@export var wind_impact:float = 2
## Controls the number of calls per second. A low value will make the rope feel rigid and stuttery.
## [br][b]Note:[/b]
## This parameter [b] significantly impacts performance.[/b]
@export_range(10,60,1,"or_greater","or_less") var call_frequency:float = 20
## Controls the simulation's precision.
## [br][b]Note:[/b]
## This parameter [b] significantly impacts performance.[/b]
@export var nbr_link_pass:int = 3

var distance:float
var points:Array[RopePoint]
var links:Array[RopeLink]
var new_delta:float

#The length of the rope compared to the distance from A to B
var line := MeshInstance3D.new()
var run_simulation:bool = false

func _init(new_start_pos:=Vector3.ZERO,new_end_pos:=Vector3.ZERO,new_wind_processor:Node=null,
		new_wind_impact:float=2,new_speed_damping:float=.2, new_rope_length_ratio:float=.7,
		new_rope_stiffness:float=1,new_gravity_strength:= Vector3(0,-20,0),new_nbr_point:int = 20) -> void:
	
	start_pos = new_start_pos
	end_pos = new_end_pos
	speed_damping = new_speed_damping
	wind_processor = new_wind_processor
	wind_impact = new_wind_impact
	rope_stiffness = new_rope_stiffness
	gravity_strength = new_gravity_strength
	nbr_point = new_nbr_point
	rope_length_ratio = new_rope_length_ratio
	add_child(line)

func _physics_process(delta:float) -> void :
	new_delta += delta
	if start_pos != end_pos and not run_simulation:
		initiate_rope()
		line = draw_multi_line(points,line)
	elif run_simulation and new_delta> 1/call_frequency:
		update_rope_variables()
		for i in range(points.size()):
			if is_instance_valid(wind_processor):
				@warning_ignore("unsafe_method_access")
				var wind_force:Vector3 = wind_processor.get_wind_strength(points[i].current_position)
				points[i].update_wind_force(wind_force,wind_impact)
			update_point_variables(points[i])
			points[i].update_point(delta)
		for i in range(0,nbr_link_pass):
			for link in links:
				update_link_variables(link)
				link.update_link()
		new_delta = 0
		line = draw_multi_line(points,line)

func initiate_rope() -> void:
	run_simulation = true
	distance = start_pos.distance_to(end_pos)
	var dir:Vector3 = start_pos.direction_to(end_pos)
	var pt_A:RopePoint
	var pt_B:RopePoint
	
	pt_A = add_point(start_pos,true)
	points.append(pt_A)
	
	for i in range(1,nbr_point-1):
		var new_pos:Vector3 = start_pos + dir * distance * rope_length_ratio * i/nbr_point
		pt_B = add_point(new_pos,false)
		points.append(pt_B)
		links.append(add_link(pt_A,pt_B))
		pt_A = pt_B
	
	pt_B = add_point(end_pos,true)
	links.append(add_link(pt_A,pt_B))
	points.append(pt_B)

func add_point(pos:Vector3,locked:bool) -> RopePoint:
	var point:RopePoint = RopePoint.new()
	point.current_position = pos
	point.previous_position = pos
	point.locked = locked
	point.gravity_strength = gravity_strength
	point.speed_damping = speed_damping
	return point

func add_link(point_a:RopePoint,point_b:RopePoint) -> RopeLink:
	var link:RopeLink = RopeLink.new()
	link.point_A = point_a
	link.point_B = point_b
	link.length = rope_length_ratio * distance/nbr_point
	link.stiffness = rope_stiffness
	return link

func draw_multi_line(line_points:Array[RopePoint],old_mesh:MeshInstance3D, color:=Color.BLACK, ) -> MeshInstance3D:
	if not line_points.size() > 0:
		return old_mesh
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	old_mesh.mesh = immediate_mesh
	old_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(line_points[0].current_position)
	for i in range(1,line_points.size()-1):
		immediate_mesh.surface_add_vertex(line_points[i].current_position)
		immediate_mesh.surface_add_vertex(line_points[i].current_position)
	immediate_mesh.surface_add_vertex(line_points[-1].current_position)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return old_mesh

func update_rope_variables() -> void:
	points[0].current_position = start_pos
	points[-1].current_position = end_pos
	distance = start_pos.distance_to(end_pos)

func update_link_variables(link:RopeLink) -> void:
	link.stiffness = rope_stiffness
	link.length = distance * rope_length_ratio / nbr_point

func update_point_variables(point:RopePoint) -> void:
	point.gravity_strength = gravity_strength
	point.speed_damping = speed_damping
