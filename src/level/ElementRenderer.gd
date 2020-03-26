extends Node2D

onready var start_time = OS.get_ticks_msec();

func _ready():
	pass

func _process(delta):
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0; # seconds
	$Canvas.material.set_shader_param("elapsed_time", elapsed_time)

	var canvas_size = get_viewport().size
	var aspect_ratio = canvas_size.x / canvas_size.y
	
	$Canvas.rect_size = canvas_size
	$Canvas.material.set_shader_param("canvas_size", canvas_size)
	
	var fluid_manager = $"../FluidManager"
	var fluid_grid = fluid_manager.create_grid()
	var fluid_tex = Texture3D.new()
	fluid_tex.create(128, 128, 8, Image.FORMAT_RGBAF)
	
	for z in range(8):
		var fluid_img = Image.new()
		fluid_img.create(128, 128, false, Image.FORMAT_RGBAF)
		fluid_img.fill(Color.black)
		fluid_img.lock()
		
		for x in range(fluid_manager.FLUID_GRID_SIZE_X):
			for y in range(fluid_manager.FLUID_GRID_SIZE_Y):
				var cell = fluid_grid[x + y * fluid_manager.FLUID_GRID_SIZE_X]
				if z >= len(cell): continue
				var fluid = cell[z]
				var pos = fluid.position / canvas_size * Vector2(aspect_ratio, 1)
				fluid_img.set_pixel(x, y, Color(pos.x, pos.y, 1, 1))
				
		fluid_tex.set_layer_data(fluid_img, z)
		fluid_img.unlock()
		
	$Canvas.material.set_shader_param("fluid_tex", fluid_tex)

	var solid_manager = $"../SolidManager"
	var solid_grid = solid_manager.solid_grid
	var solid_tex = ImageTexture.new()
	var solid_img = Image.new()
	solid_img.create(128, 64, false, Image.FORMAT_RGBAF)
	solid_img.fill(Color.black)
	solid_img.lock()
	for x in range(solid_manager.SOLID_GRID_SIZE_X):
		for y in range(solid_manager.SOLID_GRID_SIZE_Y):
			var solid = solid_manager.get_cell(x, y)
			solid_img.set_pixel(x, y, Color(solid, 0, 0, 0))
	solid_img.unlock()
	solid_tex.create_from_image(solid_img, 0)
	$Canvas.material.set_shader_param("solid_tex", solid_tex)
