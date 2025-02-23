extends Node
class_name AnimationUtils

static func load_avatar(path: String, frame_size: Vector2i) -> Sprite2D:
	var sprite = Sprite2D.new()

	var image = Image.load_from_file(path)
	if not image:
		push_error("Failed to load image from path: ", path)
		return sprite

	image.resize(frame_size.x, frame_size.y, Image.INTERPOLATE_LANCZOS)

	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	return sprite


static func load_action_animation_sheet(path: String, frame_size: Vector2i):
	return load_equipment_animation_sheet(path, frame_size)
## equipment sprite loader, assumes 4 directions to draw
static func load_equipment_animation_sheet(path: String, frame_size: Vector2i):
	var sprite_sheet = Image.load_from_file(path)
	if not sprite_sheet:
		print("could not find spritesheet for %s" % path)
		return
	var texture = ImageTexture.create_from_image(sprite_sheet)
	
	var animated_sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()
	
	var sheet_width = sprite_sheet.get_width()
	var sheet_height = sprite_sheet.get_height()
	
	var animation_types = {
		"up": 0,
		"left": 1,
		"down": 2,
		"right": 3,
	}
	
	for anim_name in animation_types:
		sprite_frames.add_animation(anim_name)
		var row = animation_types[anim_name]
		var frames = []
		var y_start = row * frame_size.y
		for x in range(0, sheet_width, frame_size.x):
			if x + frame_size.x > sheet_width:
				break
			
			var frame = sprite_sheet.get_region(Rect2(x, y_start, frame_size.x, frame_size.y))
			var frame_texture = ImageTexture.create_from_image(frame)
			frame_texture.set_size_override(Vector2i(frame_size.x,frame_size.y))
			frames.append(frame_texture)
		
		for frame_texture in frames:
			sprite_frames.add_frame(anim_name, frame_texture)
		
		sprite_frames.set_animation_speed(anim_name, 5)
		sprite_frames.set_animation_loop(anim_name, false)
	
	animated_sprite.frames = sprite_frames
	
	return animated_sprite

## FOR CHARACTER ANIMATION SHEETS! path = location of res, frame_size is w by h, assumes 3 actions x 4 dir and death
static func load_character_animation_sheet(path: String, frame_size: Vector2i):
	var sprite_sheet = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(sprite_sheet)
	
	var animated_sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()
	
	var sheet_width = sprite_sheet.get_width()
	var sheet_height = sprite_sheet.get_height()
	
	var animation_types = {
		"walk_up": 0,
		"walk_left": 1,
		"walk_down": 2,
		"walk_right": 3,
		"attack_up": 4,
		"attack_left": 5,
		"attack_down": 6,
		"attack_right": 7,
		"cast_up": 8,
		"cast_left": 9,
		"cast_down": 10,
		"cast_right": 11,
		"death": 12
	}
	
	for anim_name in animation_types:
		sprite_frames.add_animation(anim_name)
		var row = animation_types[anim_name]
		var frames = [] 
		var y_start = row * frame_size.y
		
		# Iterate through columns in the row
		for x in range(0, sheet_width, frame_size.x):
			if x + frame_size.x > sheet_width:
				break  
				
			var frame = sprite_sheet.get_region(Rect2(x, y_start, frame_size.x, frame_size.y))

			if is_frame_empty(frame):
				continue  # Skip empty frames
				
			
			var frame_texture = ImageTexture.create_from_image(frame)
			frame_texture.set_size_override(Vector2i(frame_size.x,frame_size.y))
			
			frames.append(frame_texture)
		
		
		for frame_texture in frames:
			sprite_frames.add_frame(anim_name, frame_texture)
		
		sprite_frames.set_animation_speed(anim_name, 5) 
		sprite_frames.set_animation_loop(anim_name, false)
	
	animated_sprite.frames = sprite_frames
	

	return animated_sprite

static func is_frame_empty(image: Image) -> bool:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.0:  # if any pixel has opacity, it's not empty
				return false
	return true

## only for ONE dimension of sprites
static func load_spritesheet(sprite_path: String, frame_size: Vector2i, frame_count: int, animation_name, pos, isloop):
	print("Loading sprite sheet from: ", sprite_path)
	var sprite_frames = SpriteFrames.new()
	var sprite_sheet = load(sprite_path)

	if not sprite_sheet:
		printerr("Error: Could not load sprite sheet at path: ", sprite_path)
		return

	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_loop(animation_name, isloop)

	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite_sheet
		atlas.region = Rect2(
			i * frame_size.x,   # X position
			0,                  # Y position (for horizontal sheets)
			frame_size.x, 
			frame_size.y
		)
		sprite_frames.add_frame(animation_name, atlas)

	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.position = pos
	animated_sprite.frames = sprite_frames
	animated_sprite.animation = animation_name
	animated_sprite.play(animation_name)
	print("Added AnimatedSprite2D with ", frame_count, " frames")
	
	return animated_sprite
