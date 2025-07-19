using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;

public partial class Nanda : CharacterBody2D
{
	// Start Region of Export
	[Export] public int Speed = 100;
	[Export] public float JumpVelocity = -400;
	[Export] public float Gravity = 1000;
	// [Export] public float ShakeTime = 1f;
	[Export] public float ShakeAmount = 500f;
	[Export] public int CamLimitLeft = -10000000;
	[Export] public int CamLimitTop = -10000000;
	[Export] public int CamLimitRight = 10000000;
	[Export] public int CamLimitBottom = 10000000;
	[Export] public float ZoomValue = 1F;
	// End Region of Export

	// Start Regiob of Attribute
	bool canChangeAnimate = false;
	string AnimatedSpriteName = "idle";
	Vector2[] FlipsH = [new Vector2(1, 1), new Vector2(-1, 1)];  // Original, FlipH
	private AnimatedSprite2D sprite;
	bool IsAttacking = false;
	bool IsDoubleAttacking = false;
	Camera2D Cam { get; set; }
	Vector2 CamBasePosition { get; set; }
	Node GlobalVar { get; set; }
	// End Region of Attribute

	public override void _Ready()
	{
		sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		Cam = GetNode<Camera2D>("Camera2D");
		Cam.LimitLeft = CamLimitLeft; Cam.LimitTop = CamLimitTop;
		Cam.LimitRight = CamLimitRight; Cam.LimitBottom = CamLimitBottom;
		Cam.Zoom = new Vector2(ZoomValue, ZoomValue);
		GlobalVar = GetNode<Node>("/root/Global");
	}

	public override void _PhysicsProcess(double delta)
	{
		if (!IsOnFloor())
		{
			Vector2 velocity = Velocity;
			velocity.Y += Gravity * (float)delta;
			if (velocity.Y > 0)
			{
				canChangeAnimate = false;
			}
			Velocity = velocity;
			MoveAndSlide();
		}
		if ((bool)GlobalVar.Get("CanCharMove"))
		{
			CharacterMove(delta: delta);
		}
		else
		{
			AnimatedSpriteName = "idle";
		}
		sprite.Play(AnimatedSpriteName);
		// ProcessShake();
	}
	private void CharacterMove(double delta)
	{
		Vector2 velocity = Velocity;
		bool IsOnFloorVal = IsOnFloor();
		float direction = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		// Gravity

		if (IsOnFloor())// default "ui_accept" = Space
		{
			if (Input.IsActionPressed("ui_accept"))
			{
				canChangeAnimate = false;
				velocity.Y = JumpVelocity;
				AnimatedSpriteName = "jump";
			}
			else
			{
				canChangeAnimate = true;
			}
		}
		// Movement x axis
			// sprite.Transform.X = ;
		velocity.X = direction * Speed;
		// Flip sprite
		if (canChangeAnimate)
		{
			if (direction != 0)
			{
				AnimatedSpriteName = "walk";
				sprite.FlipH = direction < 0;
			}
			else
			{
				AnimatedSpriteName = "idle";
			}
		}
		Velocity = velocity;
		MoveAndSlide();
	}
}
