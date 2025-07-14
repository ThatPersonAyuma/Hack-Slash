using Godot;
using System;

public partial class SkullWolf : CharacterBody2D
{
	[Export] public float Gravity = 1000;
	[Export] public float Speed = 65;
	[Export] public int Direction = -1;
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
			velocity.X = Direction * Speed;
		}
		Velocity = velocity;
		GD.Print($"IsInFloor: {IsOnFloorVal}, velocity: {Velocity}, direction: {Direction}");
		MoveAndSlide();
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
			rayNode2D.Position = new Vector2(rayNode2D.Position.X*-1, rayNode2D.Position.Y);
			attackArea.Position = new Vector2(attackArea.Position.X*-1, attackArea.Position.Y);
			body.Position = new Vector2(body.Position.X*-1, body.Position.Y);
			animatedSprite2D.FlipH = !animatedSprite2D.FlipH;
		}
	}
}
