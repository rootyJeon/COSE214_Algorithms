//
//  COSE214 Prof. Dogil Lee, Computer Science & Enginnering, Korea University
//  Description: Convex Hull using Bruteforce
//
//  Edited by Byungwoo Jeon, Korea University
//  Edited Date : Apr 14, 2021


#include <stdlib.h> // atoi, rand, malloc, realloc
#include <stdio.h>
#include <time.h> //time

#define RANGE 10000

typedef struct
{
	int x;
	int y;
} t_point;

typedef struct
{
	t_point from;
	t_point to;
} t_line;

////////////////////////////////////////////////////////////////////////////////
void print_header( char *filename)
{
	printf( "#! /usr/bin/env Rscript\n");
	printf( "png(\"%s\", width=700, height=700)\n", filename);
	
	printf( "plot(1:%d, 1:%d, type=\"n\")\n", RANGE, RANGE);
}
////////////////////////////////////////////////////////////////////////////////
void print_footer( void)
{
	printf( "dev.off()\n");
}

////////////////////////////////////////////////////////////////////////////////
/*
#points
points(2247,7459)
points(616,2904)
points(5976,6539)
points(1246,8191)
*/
void print_points(t_point* points, int num_point) {
	printf("\n#points\n");
	for (int i = 0; i < num_point; ++i) {
		printf("points(%d,%d)\n", points[i].x, points[i].y);
	}
	printf("\n");
}

/*
#line segments
segments(7107,2909,7107,2909)
segments(43,8,5,38)
segments(43,8,329,2)
segments(5047,8014,5047,8014)
*/
void print_line_segments(t_line* lines, int num_line) {
	printf("#line segments\n");
	for (int i = 0; i < num_line; ++i) {
		printf("segments(%d,%d,%d,%d)\n", lines[i].from.x, lines[i].from.y, lines[i].to.x, lines[i].to.y);
	}
	printf("\n");
}

// [input] points : set of points
// [input] num_point : number of points
// [output] num_line : number of line segments that forms the convex hull
// return value : set of line segments that forms the convex hull
t_line* convex_hull(t_point* points, int num_point, int* num_line) {

	t_line* vector = (t_line*)malloc(sizeof(t_line) * num_point);
	int idx = 0;

	for (int i = 0; i < num_point - 1; ++i) {
		for (int j = i + 1; j < num_point; ++j) {

			int a = points[j].y - points[i].y;
			int b = points[i].x - points[j].x;
			int c = points[i].x * points[j].y - points[i].y * points[j].x;
			int is_Left = 0, is_Right = 0, is_sameArea = 1;

			for (int k = 0; k < num_point; ++k) {
				int D = a * points[k].x + b * points[k].y - c;
				if (D < 0) is_Left = 1;
				if (D > 0) is_Right = 1;
				if (is_Left && is_Right) {
					is_sameArea = 0;
					break;
				}
			}
			if (!is_sameArea) continue;
			vector[idx].from = points[i];
			vector[idx++].to = points[j];
		}
	}
	*num_line = idx;
	return vector;
}
////////////////////////////////////////////////////////////////////////////////
int main( int argc, char **argv)
{
	int x, y;
	int num_point; // number of points
	int num_line; // number of lines
	
	if (argc != 2)
	{
		printf( "%s number_of_points\n", argv[0]);
		return 0;
	}

	num_point = atoi( argv[1]);
	if (num_point <= 0)
	{
		printf( "The number of points should be a positive integer!\n");
		return 0;
	}

	t_point *points = (t_point *) malloc( num_point * sizeof( t_point));
		
	t_line *lines;

	// making n points
	srand( time(NULL));
	for (int i = 0; i < num_point; i++)
	{
		x = rand() % RANGE + 1; // 1 ~ RANGE random number
		y = rand() % RANGE + 1;
		
		points[i].x = x;
		points[i].y = y;
 	}

	fprintf( stderr, "%d points created!\n", num_point);

	print_header( "convex.png");
	
	print_points( points, num_point);
	
	lines = convex_hull( points, num_point, &num_line);

	fprintf( stderr, "%d lines created!\n", num_line);

	print_line_segments( lines, num_line);
		
	print_footer();
	
	free( points);
	free( lines);
	
	return 0;
}
