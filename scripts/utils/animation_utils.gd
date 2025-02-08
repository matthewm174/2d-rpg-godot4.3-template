extends Node
class_name AnimationUtils

## FOR LARGER ANIMATION SHEETS! path = location of res, frame_size is w by h
static func load_animation_sheet(path: String, frame_size: Vector2i):
	var sprite_sheet = Image.load_from_file(path)  # Load the PNG file
	var texture = ImageTexture.create_from_image(sprite_sheet)  # Create a texture from the image
	
	var animated_sprite = AnimatedSprite2D.new()  # Create a single AnimatedSprite2D
	var sprite_frames = SpriteFrames.new()  # Create a SpriteFrames resource
	
	var sheet_width = sprite_sheet.get_width()  # Width of the entire sprite sheet
	var sheet_height = sprite_sheet.get_height()  # Height of the entire sprite sheet
	
	# Define animation types and their corresponding row indices
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
	
	# Iterate through each animation type
	for anim_name in animation_types:
		sprite_frames.add_animation(anim_name)
		var row = animation_types[anim_name]  # Get the row index for the animation
		var frames = []  # Array to store frames for this animation
		
		# Calculate the starting y-position for the row
		var y_start = row * frame_size.y
		
		# Iterate through columns in the row
		for x in range(0, sheet_width, frame_size.x):
			# Check if the frame is empty or beyond the sheet's width
			if x + frame_size.x > sheet_width:
				break  # End of the row reached
			
			# Extract the frame as a sub-image
			var frame = sprite_sheet.get_region(Rect2(x, y_start, frame_size.x, frame_size.y))
			var frame_texture = ImageTexture.create_from_image(frame)
			frame_texture.set_size_override(Vector2i(frame_size.x,frame_size.y))
			
			# Add the frame texture to the frames array
			frames.append(frame_texture)
		
		# Add the animation to the SpriteFrames resource
		
		for frame_texture in frames:
			sprite_frames.add_frame(anim_name, frame_texture)
		
		# Set the animation speed (optional)
		sprite_frames.set_animation_speed(anim_name, 10)  # 10 FPS, adjust as needed
		sprite_frames.set_animation_loop(anim_name, false)
	
	# Assign the SpriteFrames resource to the AnimatedSprite2D
	animated_sprite.frames = sprite_frames
	
	# Set the default animation (optional)
	#animated_sprite.animation = "walk_down"
	#animated_sprite.play()  # Start playing the default animation
	
	return animated_sprite

## only for ONE dimension of sprites
static func load_spritesheet(sprite_path: String, frame_size: Vector2i, frame_count: int, animation_name, angle, pos, isloop):
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
	animated_sprite.rotation_degrees = angle
	animated_sprite.frames = sprite_frames
	animated_sprite.animation = animation_name
	animated_sprite.play(animation_name)
	print("Added AnimatedSprite2D with ", frame_count, " frames")
	
	return animated_sprite
	#add_child(animated_sprite)
