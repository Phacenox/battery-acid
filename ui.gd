extends Control

@export_category("vars")
@export var charge = 300.0
@export var damage = 0.0
@export var passive_loss = 1.0
var baseline_canisters = 3
var canisters = 3
var orbs = 0
var desired_orbs = 3

@export_category("generation")
@export
var orb_empty: Texture2D
@export
var orb_filled: Texture2D
@export
var battery_filled: Texture2D

@export
var canister_packed: PackedScene

@export
var orbs_display: Array[TextureRect]

func _ready():
	set_orb_max(3)
	set_orb_count(0)
	render_canisters()
	$orbs/battery.visible = false

func heal(amount):
	damage -= amount
func hurt(amount):
	charge -= amount / 2
	damage += amount

func recharge(amount):
	charge += amount

func _process(delta):
	charge -= delta * passive_loss
	render_canisters()

func set_canisters(amount: int):
	canisters = amount
	var count = 0
	for i in $leftside/canisters.get_children():
		count += 1
		if count > amount:
			i.queue_free()
	for i in range(count, amount):
		$leftside/canisters.add_child(canister_packed.instantiate())

func render_canisters():
	charge = min(charge, canisters * 100 - damage)
	if(charge <= 0):
		get_tree().get_first_node_in_group("Player").kill(false)
	damage = max(damage, 0)
	var index = 0
	for c in $leftside/canisters.get_children():
		var f1 = c as TextureProgressBar
		var f2 = c.get_child(0) as TextureProgressBar
		f2.value = damage - index * 100
		f1.value = charge - (canisters - index - 1) * 100
		index += 1

func add_orb():
	set_orb_count(orbs + 1)

func add_orbs(amt):
	set_orb_count(orbs + amt)

func clear_orbs():
	set_orb_count(0)

func set_orb_count(amount: int):
	var energy_gain = (amount - orbs) * 100
	orbs = amount
	for i in range(0, desired_orbs):
		orbs_display[i].texture = orb_filled if i < amount else orb_empty
	set_canisters(orbs + baseline_canisters)
	if energy_gain > 0:
		recharge(energy_gain)

func set_orb_max(amount: int):
	damage = min(damage, amount * 100 - 300)
	desired_orbs = amount
	for i in orbs_display:
		i.visible = false
	for i in range(0, desired_orbs):
		orbs_display[i].visible = true

func show_battery_ui():
	$orbs/battery.visible = true

var has_battery = false
func collect_battery():
	recharge(300)
	heal(300)
	has_battery = true
	$orbs/battery.texture = battery_filled