class Player
  def play_turn(warrior)
    @warrior = warrior
	@ticking = listen.select(&:ticking?)
	@captives = listen.select(&:captive?)
	@enemies = listen.select(&:enemy?)
	catch(:end_turn) { turn }
    @health = health
  end
    
  def initialize
	@health = 20
	@previous = nil
  end
  
  # Get rid of the warrior.everything
  def method_missing(sym, *args, &block)
    ret = @warrior.send(sym, *args, &block)
	throw :end_turn if sym=~ /!$/
	ret
  end
  
  def turn
	bind!(direction_to_enemy?) if multiple_enemies?
	detonate! if look.first(2).select(&:enemy?).size > 1 && health > 4 && distance_of(listen.find(&:captive?)) > 2
	rest if health < 6 && listen.size > 0
  ticking_action if listen.select(&:ticking?).size > 0
	retreat if health < 5 && health < @health
	attack!(direction_to_enemy?) if direction_to_enemy? != nil
	rest if health < 16 && listen.size > 0
	rescue_captive if direction_to_captive? != nil
	continue
  end
  
  def direction_to_enemy?
	return :backward if feel(:backward).enemy?
	return :forward if feel.enemy?
	return :right if feel(:right).enemy?
	return :left if feel(:left).enemy?
	return nil
  end
  
  def direction_to_captive?
	return :forward if feel.captive?
	return :backward if feel(:backward).captive?
	return :left if feel(:left).captive?
	return :right if feel(:right).captive?
	return nil
  end
  
  def direction_to_ticking?
	return :forward if feel.ticking?
	return :left if feel(:left).ticking?
	return :right if feel(:right).ticking?
	return :backward if feel(:backward).ticking?
	return nil
  end
  
  def multiple_enemies?
	@enemies = 0
	@enemies += 1 if feel.enemy?
	@enemies += 1 if feel(:backward).enemy?
	@enemies += 1 if feel(:left).enemy?
	@enemies += 1 if feel(:right).enemy?
	return @enemies > 1
  end
  
  def rest
	rest!
  end
  
  def retreat
	walk!(@previous)
  end
  
  def continue
    walk!(to_captive) if listen.select(&:captive?).size > 0
	walk!(to_enemy) if listen.select(&:enemy?).size > 0	
	walk!(direction_of_stairs)
  end
  
  def to_captive
	if feel(direction_of(listen.first(&:captive?))).stairs?  || !feel(direction_of(listen.first(&:captive?))).empty?
	  return :forward if feel.empty? && !feel.stairs?
	  return :left if feel(:left).empty? && !feel(:left).stairs?
	  return :right if feel(:right).empty? && !feel(:right).stairs?
	  return :backward if feel(:backward).empty? && !feel(:backward).stairs?
	else
		return direction_of(listen.first(&:captive?))
	end
  end
  
  def to_enemy
  	if feel(direction_of(listen.first(&:enemy?))).stairs? || !feel(direction_of(listen.first(&:enemy?))).empty?
	  return :forward if feel.empty? && !feel.stairs?
	  return :left if feel(:left).empty? && !feel(:left).stairs?
	  return :right if feel(:right).empty? && !feel(:right).stairs?
	  return :backward if feel(:backward).empty? && !feel(:backward).stairs?
	else
	  return direction_of(listen.first(&:enemy?))
	end
  end
  
  def to_ticking
  	if feel(direction_of(@ticking[0])).empty?
	  return direction_of(@ticking[0])
	else
	  return :forward if feel.empty?
	  return :left if feel(:left).empty?
	  return :right if feel(:right).empty?
	  return :backward if feel(:backward).empty?
	end
  end
  
  def to_stairs
	if !feel(direction_of_stairs).empty?
	  return :forward if feel.empty? || feel.stairs?
	  return :left if feel(:left).empty? || feel(:left).stairs?
	  return :right if feel(:right).empty? || feel(:right).stairs?
	  return :backward if feel(:backward).empty? || feel(:backward).stairs?
	else
	  return direction_of_stairs
	end
  end
  
  def rescue_captive
	rescue!(direction_to_captive?)
  end
  
  def ticking_action
	rescue!(direction_to_ticking?) if direction_to_ticking? != nil
	if (to_ticking != @previous)
	  @previous = invert(to_ticking)
	  walk!(to_ticking)
	end
  end
  
  def invert(direction)
    return :right if direction == :left
	return :left if direction == :right
	return :forward if direction == :backward
	return :backward if direction == :forward
  end
end
