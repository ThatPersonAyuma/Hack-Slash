using Godot;
using System;

public partial class BringerOfDeath : CharacterBody2D
{
	[Export] public float Gravity = 1000;
	[Export] public float Speed = 50;
	[Export] public int Direction = -1;
	[Export] public float WalkingColdown = 1.5F;
	float WalkingColdownTimer = 0F;
	string AnimatedName { get; set; }
	bool IsWalk { get; set; }
	RayCastFloor rayNode2D { get; set; }
	Area2D attackArea { get; set; }
	CollisionShape2D body { get; set; }
	AnimatedSprite2D animatedSprite2D { get; set; }
	public override void _Ready()
	{
		rayNode2D = GetNode<RayCastFloor>("RayCastFloor");
		body = GetNode<CollisionShape2D>("Body");
		animatedSprite2D = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		attackArea = GetNode<Area2D>("MeleeArea");
		rayNode2D.Connect(RayCastFloor.SignalName.NotCollided, new Callable(this, nameof(ChangeDirection)));
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
		bool IsOnFloorVal = IsOnFloor();
		if (!IsOnFloorVal)
		{
			velocity.Y += Gravity * (float)delta;
		}
		else
		{
			if (WalkingColdownTimer > 0)
			{
				WalkingColdownTimer -= (float)delta;
			}
			else
			{
				IsWalk = !IsWalk;
				WalkingColdownTimer = WalkingColdown;
			}
			if (IsWalk)
			{
				velocity.X = Direction * Speed;
				AnimatedName = "walk";
			}
			else
			{
				velocity.X = 0;
				AnimatedName = "idle";
			}
		}
		Velocity = velocity;
		GD.Print($"IsInFloor: {IsOnFloorVal}, velocity: {Velocity}, direction: {Direction}");
		MoveAndSlide();
		animatedSprite2D.Play(AnimatedName);
		//GD.Print(Velocity);
	}
	// void CharMove(Vector2 velocity)
	// {

	// 	return velocity;
	// }
	public void ChangeDirection()
	{
		if (IsOnFloor())
		{
			Direction *= -1;
			GlobalPosition = new Vector2(GlobalPosition.X + 70*Direction, GlobalPosition.Y); // 48
			rayNode2D.Position = new Vector2(rayNode2D.Position.X*-1, rayNode2D.Position.Y);
			attackArea.Scale = new Vector2(attackArea.Scale.X*-1, attackArea.Scale.Y);
			body.Position = new Vector2(body.Position.X*-1, body.Position.Y);
			animatedSprite2D.FlipH = !animatedSprite2D.FlipH;
		}
	}
}
