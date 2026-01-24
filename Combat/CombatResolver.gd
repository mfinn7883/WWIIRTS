extends Node
var active_units: Dictionary = {}

func resolve_combat(attacker: UnitData, defender: UnitData):
	print("Attacker: ", attacker.unit_name, ", ID: ", attacker.unit_id, " vs Defender: ", defender.unit_name, ", ID: ", defender.unit_id)
	
	# Simple math: Damage = Attack Power * Morale
	var damage_to_defender = attacker.attack_power * attacker.morale
	var damage_to_attacker = (defender.attack_power * defender.morale) * 0.5 # Defender hits back weaker
	
	defender.strength -= damage_to_defender
	attacker.strength -= damage_to_attacker
	
	print("Defender: ", defender.unit_name, " HP: ", defender.strength)
	print("Attacker: ", attacker.unit_name, " HP: ", attacker.strength)

	# Check for deaths
	if defender.strength <= 0:
		print(defender.unit_name, " was destroyed!")
		active_units.erase(defender.unit_id)
		return true # Defender died
	return false # Defender survived
