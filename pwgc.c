//
//  COSE214 Prof. Dogil Lee, Computer Science & Enginnering, Korea University
//  Description: River Crossing Puzzle Problem (PWGC)
//
//  Edited by Byungwoo Jeon, Korea University
//  Edited Date : May 25, 2021

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

#define PEASANT 0x08
#define WOLF	0x04
#define GOAT	0x02
#define CABBAGE	0x01

// 주어진 상태 state의 이름(마지막 4비트)을 화면에 출력
// 예) state가 7(0111)일 때, "<0111>"을 출력
static void print_statename(FILE *fp, int state);

// 주어진 상태 state에서 농부, 늑대, 염소, 양배추의 상태를 각각 추출하여 p, w, g, c에 저장
// 예) state가 7(0111)일 때, p = 0, w = 1, g = 1, c = 1
static void get_pwgc(int state, int* p, int* w, int* g, int* c);

// 허용되지 않는 상태인지 검사
// 예) 농부없이 늑대와 염소가 같이 있는 경우 / 농부없이 염소와 양배추가 같이 있는 경우
// return value: 1 허용되지 않는 상태인 경우, 0 허용되는 상태인 경우
static int is_dead_end(int state);

// state1 상태에서 state2 상태로의 전이 가능성 점검
// 농부 또는 농부와 다른 하나의 아이템이 강 반대편으로 이동할 수 있는 상태만 허용
// 허용되지 않는 상태(dead-end)로의 전이인지 검사
// return value: 1 전이 가능한 경우, 0 전이 불이가능한 경우 
static int is_possible_transition(int state1, int state2);

// 상태 변경: 농부 이동
// return value : 새로운 상태
static int changeP(int state);

// 상태 변경: 농부, 늑대 이동
// return value : 새로운 상태, 상태 변경이 불가능한 경우: -1
static int changePW(int state);

// 상태 변경: 농부, 염소 이동
// return value : 새로운 상태, 상태 변경이 불가능한 경우: -1
static int changePG(int state);

// 상태 변경: 농부, 양배추 이동
// return value : 새로운 상태, 상태 변경이 불가능한 경우: -1 
static int changePC(int state);

// 주어진 state가 이미 방문한 상태인지 검사
// return value : 1 visited, 0 not visited
static int is_visited(int visited[], int level, int state);

// 방문한 상태들을 차례로 화면에 출력
static void print_states(int visited[], int count);

// recursive function
static void dfs_main(int state, int goal_state, int level, int visited[]);

////////////////////////////////////////////////////////////////////////////////
// 상태들의 인접 행렬을 구하여 graph에 저장
// 상태간 전이 가능성 점검
// 허용되지 않는 상태인지 점검 
void make_adjacency_matrix(int graph[][16]);

// 인접행렬로 표현된 graph를 화면에 출력
void print_graph(int graph[][16], int num);

// 주어진 그래프(graph)를 .net 파일로 저장
// pgwc.net 참조
void save_graph(char* filename, int graph[][16], int num);

////////////////////////////////////////////////////////////////////////////////
// 깊이 우선 탐색 (초기 상태 -> 목적 상태)
void depth_first_search( int init_state, int goal_state)
{
	int level = 0;
	int visited[16] = {0,}; // 방문한 정점을 저장
	
	dfs_main( init_state, goal_state, level, visited); 
}

////////////////////////////////////////////////////////////////////////////////
int main( int argc, char **argv)
{
	int graph[16][16] = {0,};
	
	// 인접 행렬 만들기
	make_adjacency_matrix( graph);

	// 인접 행렬 출력 (only for debugging)
	//print_graph( graph, 16);
	
	// .net 파일 만들기
	save_graph( "pwgc.net", graph, 16);

	// 깊이 우선 탐색
	depth_first_search( 0, 15); // initial state, goal state
	
	return 0;
}

//////////////////////////////////

static void print_statename(FILE *fp, int state) {
	int p, w, g, c;
	get_pwgc(state, &p, &w, &g, &c);
	fprintf(fp, "<%d%d%d%d>", p, w, g, c);
}

static void get_pwgc(int state, int* p, int* w, int* g, int* c) {
	int tmp = state;
	for (int i = 0; i < 4; ++i) {
		int val = tmp % 2;
		switch (i) {
		case 0:
			*c = val;
			break;
		case 1:
			*g = val;
			break;
		case 2:
			*w = val;
			break;
		case 3:
			*p = val;
			break;
		}
		tmp /= 2;
	}
}

static int is_dead_end(int state) {
	if ((state >= 6 && state <= 9) || state == 3 || state == 12)
		return 1;
	return 0;
}

static int is_possible_transition(int state1, int state2) {
	if (is_dead_end(state1) || is_dead_end(state2)) return 0;
	if (changeP(state1) == state2) return 1;
	if (changePW(state1) == state2) return 1;
	if (changePG(state1) == state2) return 1;
	if (changePC(state1) == state2) return 1;
	return 0;
}

static int changeP(int state) {
	if (state < 8)
		return state + 8;
	return state - 8;
}

static int changePW(int state) {
	if (state >= 0 && state <= 3)
		return state + 12;
	if (state >= 12 && state <= 15)
		return state - 12;
	return -1;
}

static int changePG(int state) {
	if (state == 0 || state == 1 || state == 4 || state == 5)
		return state + 10;
	if (state == 10 || state == 11 || state == 14 || state == 15)
		return state - 10;
	return -1;
}

static int changePC(int state) {
	if (state == 0 || state == 2 || state == 4 || state == 6)
		return state + 9;
	if (state == 9 || state == 11 || state == 13 || state == 15)
		return state - 9;
	return -1;
}

static int is_visited(int visited[], int level, int state) {
	for (int i = 0; i < level; ++i) {
		if (visited[i] == state) return 1;
	}
	return 0;
}

static void print_states(int visited[], int count) {
	fprintf(stdout, "Goal-state found!\n");
	for (int i = 0; i < count; ++i) {
		print_statename(stdout, visited[i]);
		fprintf(stdout, "\n");
	}
	fprintf(stdout, "\n");
}

static void dfs_main(int state, int goal_state, int level, int visited[]) {
	visited[level] = state;
	fprintf(stdout, "cur state is ");
	print_statename(stdout, state);
	fprintf(stdout, " (level %d)\n", level);
	level++;

	if (state == goal_state) {
		print_states(visited, level);
		return;
	}

	int iter = 4;
	while(iter--) {
		int i;
		if (iter == 3) i = changeP(state);
		if (iter == 2) i = changePW(state);
		if (iter == 1) i = changePG(state);
		if (iter == 0) i = changePC(state);

		if (i == -1) continue;
		if (is_dead_end(i)) { // 전이 불가능
			fprintf(stdout, "\tnext state ");
			print_statename(stdout, i);
			fprintf(stdout, " is dead-end\n");
		}
		else if (is_visited(visited, level, i)) { // 전위 가능 중 이미 방문함
			fprintf(stdout, "\tnext state ");
			print_statename(stdout, i);
			fprintf(stdout, " has been visited\n");
		}
		else { // 전위 가능하면서 방문하지 않음
			dfs_main(i, goal_state, level, visited); 
			fprintf(stdout, "back to ");
			print_statename(stdout, state);
			fprintf(stdout, " (level %d)\n", level - 1);
		}
	}
}

void make_adjacency_matrix(int graph[][16]) {
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			if (is_possible_transition(i, j))
				graph[i][j] = 1;
		}
	}
}

void print_graph(int graph[][16], int num) {
	for (int i = 0; i < num; ++i) {
		for (int j = 0; j < num; ++j) {
			fprintf(stdout, "%d\t", graph[i][j]);
		}
		fprintf(stdout, "\n");
	}
}

void save_graph(char* filename, int graph[][16], int num) {
	FILE* out;
	out = fopen(filename, "w");

	fprintf(out, "*Vertices %d\n", num);
	for (int i = 0; i < num; ++i) {
		fprintf(out, "%d \"", i + 1);
		print_statename(out, i);
		fprintf(out, "\"\n");
	}
	fprintf(out, "*Edges\n");
	for (int i = 0; i < num; ++i) {
		for (int j = i; j < num; ++j) {
			if (graph[i][j] == 1)
				fprintf(out, "\t%d\t%d\n", i + 1, j + 1);
		}
	}
	fclose(out);
}