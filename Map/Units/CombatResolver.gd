extends Node
var active_units: Dictionary = {}

func resolve_combat(attacker: UnitData, defender: UnitData):
	print("COMBAT: ", attacker.unit_name, " vs ", defender.unit_name)
	
	# Simple math: Damage = Attack Power * Morale
	var damage_to_defender = attacker.attack_power * attacker.morale
	var damage_to_attacker = (defender.attack_power * defender.morale) * 0.5 # Defender hits back weaker
	
	defender.strength -= damage_to_defender
	attacker.strength -= damage_to_attacker
	
	print(defender.unit_name, " HP: ", defender.strength)
	print(attacker.unit_name, " HP: ", attacker.strength)

	# Check for deaths
	if defender.strength <= 0:
		print(defender.unit_name, " was destroyed!")
		active_units.erase(defender.unit_id)
		return true # Defender died
	return false # Defender survived
