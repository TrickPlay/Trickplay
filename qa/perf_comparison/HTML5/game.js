var x;
var y;
var dx=4;
var dy=4;
var WIDTH=960;
var HEIGHT=540;
var ball_size=20;
var ctx;
var backcolor = "#000000";
var num_balls = 60;
var carray = new Array();

function init() {
	widgetAPI.sendReadyEvent();
	canvas = document.getElementById('example');  
    ctx = canvas.getContext('2d');    
	for (i=0; i<=num_balls;i++) {
		var ball_color = Math.floor(Math.random()*(1+3-1))+1;
		if (ball_color == 1) 
		{
  			carray[i] = new Circle(Math.random()*1000,Math.random()*500,ball_size,"FF0000");
		}
		else if (ball_color == 2)
		{
  			carray[i] = new Circle(Math.random()*1000,Math.random()*500,ball_size,"00FF00");
		}
		else
		{
  			carray[i] = new Circle(Math.random()*1000,Math.random()*500,ball_size,"0000FF");
		}
 	 }
  	setInterval(draw,10);
}

function clear() {
	ctx.fillStyle = "#000";
	ctx.fillRect(0, 0, WIDTH, HEIGHT)
	ctx.fillStyle    = '#FFF';

	ctx.font         = '25px sans';
	ctx.fillText  ('HTML5 Bouncing Balls', 10, 30);
//	ctx.font         = '20px sans';
//	ctx.fillText  ('Total Balls = '+num_balls, 10, 60);
//	ctx.fillText  ('Resolution = '+myCanvas.width+', '+myCanvas.height, 10, 90);

}

// Circle Class	
function Circle(x,y,r,color)
{	
	this.x = x;
	this.y = y;
	this.r = r/2;
	this.dx = Math.ceil(Math.random()*9);
	this.dy = Math.ceil(Math.random()*9);
	
	this.draw = function()
	{
		ctx.beginPath();
		ctx.fillStyle = color;
		ctx.arc(this.x, this.y, this.r, 0, Math.PI*2, true);
		ctx.closePath();
		ctx.fill();
	}
	
	this.getX = function()
	{
		return x;
	}
	
	this.getY = function()
	{
		return this.y;
	}

	this.move = function()
	{	
		this.x += this.dx;
		this.y += this.dy;
	
		if(this.x > WIDTH || this.x < 0)
		{
			this.dx = this.dx*-1;
		}
		
		if(this.y > HEIGHT || this.y < 0)
		{
			this.dy = this.dy*-1;
		}
	}

/*	
	this.collision_check = function(ballB)
	{	
		var ballA_x = this.getX();
		var ballA_y = this.getY();
		var ballB_x = ballB.getX();
		var ballB_y = ballB.getY();	
		var dx = ballB_x - ballA_x;
		var dy = ballB_y - ballA_y;
		var dist = Math.sqrt (dx*dx+dy*dy);
		alert ('dist = '+dist);
		if (dist<25) 
		{
			return true;
			alert (dist);
		}
		else 
		{
			return false;
		}
	}
*/

}

function rect(x,y,w,h) {
  ctx.beginPath();
  ctx.rect(x,y,w,h);
  ctx.closePath();
  ctx.fill();
}
/*
function solveBalls (ballA, ballB)
{
	var x1 = ballA.getX();
	var y1 = ballA.getY();
	var dx = ballB.getX()-x1;
	var dy = ballB.getY()-y1;
	var dist = math.sqrt ( dx*dx+dy*dy );
	var radius = ball_size /2;

	normalX = dx/dist
	normalY = dy/dist
	midpointX = (x1+ballB.x)/2
	midpointY = (y1+ballB.y)/2
	ballA.x = midpointX-normalX*radius
	ballA.y = midpointY-normalY*radius
	ballB.x = midpointX+normalX*radius
	ballB.y = midpointY+normalY*radius
	
	dVector = (ballA.speedx-ballB.speedx)*normalX+(ballA.speedy-ballB.speedy)*normalY
	dvx = dVector*normalX
	dvy = dVector*normalY
	ballA.speedx = ballA.speedx - dvx
	ballA.speedy = ballA.speedy - dvy
	ballB.speedx = ballB.speedx + dvx
	ballB.speedy = ballB.speedy + dvy


}
*/

function draw()
{
	clear();
	var i;
	for (i=0; i<carray.length-1; i++)
	{
		ballA = carray[i];
		ballA.move();
		ballA.draw();
/*
		for (j=i+1; j<carray.length - 1; j++)
		{
			var ballB = carray[j];
			var ballB_x = ballB.getX();
			var ballB_y = ballB.getY();
			var ballA_x = ballA.getX();
			var ballA_y = ballA.getY();
			var dx = ballB_x - ballA_x;
			var dy = ballB_y - ballA_y;
			var dist = Math.sqrt (dx*dx+dy*dy);

			if (dist<20) 
			{
				solveBalls (ballA, ballB);
			}

		}
		*/
	}
}


init();