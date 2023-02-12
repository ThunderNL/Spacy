scale = 2
ship = {}
bullet = {}
bullets = {}
rock = {}
rocks = {}
ship.image = nil
bullet.image = nil
background = nil
rock.image = nil
score = 0
hearts = 3
time = 0
topbar = scale*12
font = love.graphics.newFont("font.ttf", topbar)
love.graphics.setFont(font)
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
rockSpawnTimerMax = 0.5
rockSpawnTimer = rockSpawnTimerMax
ship.speed = 500


function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    randomship = math.random(1,2)
    shippng = "ship"..randomship..".png"
    ship.image = love.graphics.newImage(shippng)
    background = love.graphics.newImage("nebula.png")
    rock.image = love.graphics.newImage("rock.png")
    ship.x = 0
    ship.y = love.graphics:getHeight()/2
    bullet.image = love.graphics.newImage("laser.png")
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
	end
end

function love.update(dt)

   if love.keyboard.isDown('w', 'up') and ship.y > topbar then
     ship.y = ship.y - (ship.speed * dt)
   elseif love.keyboard.isDown('s', 'down') and ship.y < love.graphics.getHeight() - ship.image:getHeight()*2 then
     ship.y = ship.y + (ship.speed * dt)
   end
 
   if ship.y > love.graphics.getHeight() - ship.image:getHeight()*2 then
     ship.y = love.graphics.getHeight() - ship.image:getHeight()*2
   end
   
   if love.keyboard.isDown('space', 'return', 'lshift', 'rshift') and canShoot and hearts > 0 then
     newbullet = {x = ship.x + (ship.image:getWidth()/2*scale), y = ship.y + (ship.image:getHeight()/2*scale), img = bullet.image}
     table.insert(bullets, newbullet)
     canShoot = false
     canShootTimer = canShootTimerMax
     score = score -1
   end
   

 for i, bullet in ipairs(bullets) do
   if hearts > 0 then
	bullet.x = bullet.x + (500 * dt)
end

  	if bullet.x > love.graphics.getWidth() then
		table.remove(bullets, i)
    score = score -1
	end
end
  
canShootTimer = canShootTimer - dt
if canShootTimer < 0 then
  canShoot = true
end
  
rockSpawnTimer = rockSpawnTimer - dt
if rockSpawnTimer < 0 then
  rockSpawnTimer = rockSpawnTimerMax
  
  randomSpawnY = math.random(topbar+rock.image:getHeight()/2, love.graphics.getHeight()-rock.image:getHeight()/2)
  newRock = {x = love.graphics.getWidth(), y = randomSpawnY, img = rock.image}
  table.insert(rocks, newRock)
end
  
  for i, rock in ipairs(rocks) do
  if hearts > 0 then
  rock.x = rock.x - (200 * dt)
end

     if rock.x < -rock.img:getWidth()*scale then
     table.remove(rocks, i)
     score = score -1
     end
  end
  
 if score < 0 then
   score = 0
 end
  
if hearts > 0 then
 time = time + dt
end
 
 for i, rock in ipairs(rocks) do
	for j, bullet in ipairs(bullets) do
		if CheckCollision(rock.x, rock.y, rock.img:getWidth()*scale, rock.img:getHeight()*scale, bullet.x, bullet.y, bullet.img:getWidth()*scale, bullet.img:getHeight()*scale) then
			table.remove(bullets, j)
			table.remove(rocks, i)
			score = score +1
		end
	end

	if CheckCollision(rock.x, rock.y, rock.img:getWidth()*scale, rock.img:getHeight()*scale, ship.x, ship.y, ship.image:getWidth()*scale, ship.image:getHeight()*scale) then
		table.remove(rocks, i)
		hearts = hearts-1
	end
end
 
 if hearts < 1 and love.keyboard.isDown('r') then
	bullets = {}
	rocks = {}

	canShootTimer = canShootTimerMax
	rockSpawnTimer = rockSpawnTimerMax

    ship.x = 0
    ship.y = love.graphics:getHeight()/2

	score = 0
  time = 0
	hearts = 3
end
 
end

function love.draw(dt)
    for j = 0, love.graphics.getWidth()*scale / background:getWidth()*scale do
        for k = 0, love.graphics.getHeight()*scale / background:getHeight()*scale do
            love.graphics.draw(background, j * background:getWidth()*scale, k * background:getHeight()*scale, nil, scale, scale)
        end
    end
    
    for i, rock in ipairs(rocks) do
      love.graphics.draw(rock.img, rock.x, rock.y, nil, scale, scale)
    end
    
    
    for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y, nil, scale, scale, 0, bullet.img:getHeight()/2)
    end
    
    if hearts > 0 then
    love.graphics.draw(ship.image, ship.x, ship.y, nil, scale, scale)
  else
    love.graphics.print("Press 'R' to restart", 0, love.graphics.getHeight()/3)
    love.graphics.print("Total score: "..string.format("%.2f", score*math.sqrt(time)), 0, love.graphics.getHeight()/2)
    end
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), topbar)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: "..score, love.graphics.getWidth()/4, 0)
    love.graphics.print("Health: "..hearts, love.graphics.getWidth()/2, 0)
    love.graphics.print("Time: "..string.format("%.2f", time), love.graphics.getWidth()*3/4, 0)
end