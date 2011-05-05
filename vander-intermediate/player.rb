class Player
  def play_turn(warrior)
	@warrior = warrior;
	bind and return if multiple_enemies
	retreat and return if warrior.health < 5 && warrior.health < @health
	attack and return if direction_to_enemy != nil
	rest and return if warrior.health < 16
	rescue_captive and return if direction_to_captive != nil
	move and return if warrior.listen.length > 0
	continue
  end
  
  def direction_to_enemy
	if @warrior.feel.enemy?
		return :forward
	elsif @warrior.feel(:backward).enemy?
		return :backward
	elsif @warrior.feel(:left).enemy?
		return :left
	elsif @warrior.feel(:right).enemy?
		return :right
	else
		return nil
	end
  end
  
  def direction_to_captive
	if @warrior.feel.captive?
		return :forward
	elsif @warrior.feel(:backward).captive?
		return :backward
	elsif @warrior.feel(:left).captive?
		return :left
	elsif @warrior.feel(:right).captive?
		return :right
	else
		return nil
	end
  end
  
  def multiple_enemies
	@enemies = 0
	if @warrior.feel.enemy?
		@enemies += 1
	end
	if @warrior.feel(:backward).enemy?
		@enemies += 1
	end
	if @warrior.feel(:left).enemy?
		@enemies += 1
	end
	if @warrior.feel(:right).enemy?
		@enemies += 1
	end
	return @enemies > 1
  end
  
  def rest
	@warrior.rest!
	@health = @warrior.health
  end
  
  def retreat
	if @warrior.feel(:backward).empty?
		@warrior.walk!(:backward)
	elsif @warrior.feel(:left).empty?
		@warrior.walk!(:left)
	elsif @warrior.feel(:right).empty?
		@warrior.walk!(:right)
	elsif @warrior.feel.empty?
		@warrior.walk!
	end
	@health = @warrior.health
  end
  
  def continue
	@warrior.walk!(@warrior.direction_of_stairs)
	@health = @warrior.health
  end
  
  def attack
    @warrior.attack!(direction_to_enemy)
	@health = @warrior.health
  end
  
  def bind
	@warrior.bind!(direction_to_enemy)
	@health = @warrior.health
  end
  
  def rescue_captive
	@warrior.rescue!(direction_to_captive)
	@health = @warrior.health
  end
  
  def move
	if @warrior.direction_of(@warrior.listen.first.captive?) != nil
		@warrior.move!(warrior.direction_of(@warrior.listen.first.captive?))
	end
  end
end
