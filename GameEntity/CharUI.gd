extends Node2D

var NORMAL_STACK = false	#normal can stack
var SPEC_STACK = false		#special can stack
var N_STACK_MAX = 3			#max stack count of normal
var S_STACK_MAX = 3			#max stack count of special
var H2_A = false			#has 1 party mem
var H3_A = false			#has 2 party mem
var S_CHARGE_MODE = 0		#0 if auto charge, else offensive charge
var N_COOLDOWN = 1			#auto, in sec
var S_COOLDOWN = 1			#check s_charge_mode, 0 - sec, 1 - attacks hit
var N_ANIM_DUR = 1			#animation duration, for stacks so no need to wait for actual cooldown
var S_ANIM_DUR = 1

var n_stack_count = 0
var s_stack_count = 0

var n_value = 0
var s_value = 0

var n_cooldown_counter = 0	# to keep from multiple clicks from registering even if animation cooldown not yet done
var s_cooldown_counter = 0

var small_hp_id = 1			#1,2, or 3

func _ready():
	update_items()
	if H2_A:
		$Small_heart_2.visible = false
	if H3_A:
		$Small_heart_3.visible = false
		
	n_cooldown_counter = N_ANIM_DUR
	s_cooldown_counter = S_ANIM_DUR

func _process(delta):
	if n_value < N_COOLDOWN:
		n_value += delta;
		
	if !S_CHARGE_MODE:
		s_value += delta
	
	if n_cooldown_counter <= N_ANIM_DUR:
		n_cooldown_counter += delta
		
	if s_cooldown_counter <= S_ANIM_DUR:
		s_cooldown_counter += delta
	
	if NORMAL_STACK and n_stack_count < N_STACK_MAX:
		if n_value >= N_COOLDOWN:
			Skill_normal_update(1)
			
	if SPEC_STACK and s_stack_count < S_STACK_MAX:
		if s_value >= S_COOLDOWN:
			Skill_special_update(1)
			
	update_skill_values()

func update_shp_self(n,d):
	if small_hp_id == 1:
		update_shp_1((n*100)/d)
	elif small_hp_id == 2:
		update_shp_2((n*100)/d)
	else:
		update_shp_3((n*100)/d)

func update_HP(n,d):
	$HP_bar.value = (n * 100)/d
	
func update_shp_1(v):
	$Small_heart_1.value = v
	
func update_shp_2(v):
	$Small_heart_2.value = v
	
func update_shp_3(v):	
	$Small_heart_3.value = v

func update_skill_values():
	$Skill_normal.value = (n_value/N_COOLDOWN) * 100
	$Skill_special.value = (s_value/S_COOLDOWN) * 100

func Skill_normal_update(n):
	if NORMAL_STACK:
		#if 1, it means increase stack, else it means decrease
		#the elif are for decreasing, if there is stack, dont reduce n_value, only stack
		if n == 1:	
			n_stack_count = min(n_stack_count+1,N_STACK_MAX)
			n_value = 0
		elif n_stack_count > 0 and n_cooldown_counter >= N_ANIM_DUR:
			n_stack_count = max(n_stack_count-1,0)
			n_cooldown_counter = 0
	else:
		if n_value >= N_COOLDOWN:
			n_value = 0
	Update_normal_anim()

func Skill_special_update(n):
	if SPEC_STACK and s_value >= S_COOLDOWN:
		if n == 1:
			s_stack_count = min(s_stack_count+1,S_STACK_MAX)
			s_value = 0
		elif s_stack_count > 0 and s_cooldown_counter >= S_ANIM_DUR:
			s_stack_count = max(s_stack_count-1,0)
			s_cooldown_counter = 0
	else:
		if s_value >= S_COOLDOWN:
			s_value = 0
	Update_special_anim()

func Update_normal_anim():
	if NORMAL_STACK:
		if n_stack_count == 0:
			$Skill_n_status.play("shade")
		elif n_stack_count == 1:
			$Skill_n_status.play("s1")
		elif n_stack_count == 2:
			$Skill_n_status.play("s2")
		elif n_stack_count == 3:
			$Skill_n_status.play("s3")
		elif n_stack_count == 4:
			$Skill_n_status.play("s4")
		elif n_stack_count == 5:
			$Skill_n_status.play("s5")
		elif n_stack_count == 6:
			$Skill_n_status.play("s6")
	else:
		if n_value >= N_COOLDOWN:
			$Skill_n_status.play("none")
		else:
			$Skill_n_status.play("shade")
			
func Update_special_anim():
	if SPEC_STACK:
		if s_stack_count == 0:
			$Skill_s_status.play("shade")
		elif s_stack_count == 1:
			$Skill_s_status.play("s1")
		elif s_stack_count == 2:
			$Skill_s_status.play("s2")
		elif s_stack_count == 3:
			$Skill_s_status.play("s3")
		elif s_stack_count == 4:
			$Skill_s_status.play("s4")
		elif n_stack_count == 5:
			$Skill_s_status.play("s5")
		elif s_stack_count == 6:
			$Skill_s_status.play("s6")
	else:
		if s_stack_count == 0:
			$Skill_s_status.play("shade")
		else:
			$Skill_s_status.play("none")

func update_items():
	var item_1_name = GameHandler.item1
	var temp = get_item_animation(item_1_name)
	$Item_1_icon.play(temp[0])
	$Item_1_icon.frame = temp[1]
	var item_2_name = GameHandler.item2
	temp = get_item_animation(item_2_name)
	$Item_2_icon.play(temp[0])
	$Item_2_icon.frame = temp[1]
		
func get_item_animation(x):
	if "collab" in x:
		return ["tickets", item_frame_char(x.to_lower())]
	if "switch" in x:
		return ["char_switch", item_frame_char(x.to_lower())]

func item_frame_char(x):
	if "flare" in x:
		return 2
	if "noel" in x:
		return 3
	if "pekora" in x:
		return 4
