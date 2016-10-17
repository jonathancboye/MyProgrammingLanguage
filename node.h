#ifndef NODE_H
#define NODE_H
//File: node.h
//Author: Jonathan Carpenter

//Node for a abstract syntax tree
typedef struct _node_t node_t;
typedef struct _class_t class_t;
typedef struct _ivars_t ivars_t;
typedef struct _svars_t svars_t;

//Function pointer
typedef node_t *(*funptr)(node_t *self);

struct _node_t {
  int value;
  char *strvalue;
  class_t *obj;
  funptr fun;
  node_t *left;
  node_t *center;
  node_t *right;
};

struct _class_t
{
  class_t *parent;
  ivars_t *ivars;
  svars_t *svars;
  char *name;
};

struct _ivars_t
{
  char *names[10];
  int values[10];
  int num_vars;
};

struct _svars_t
{
  char *names[10];
  char *values[10];
  int num_vars;
};

extern node_t *getStrVarNode(node_t* self);

extern node_t *getIntVarNode(node_t* self);

extern node_t *addIntVarNode(node_t* self);

extern node_t *addStrVarNode(node_t* self);

extern node_t *makeClassNode(char *name, class_t *parent);

extern  node_t *makeNode(node_t *left, node_t *center,  node_t *right, funptr fun);

extern node_t *makeValueNode(int value);

extern node_t *makeIntNode(int value);

extern node_t *makeStrNode(char* value);

extern node_t *makeRandStrNode();



extern node_t *getValue(node_t *self);

extern node_t *add(node_t *self);

extern node_t *subtract(node_t *self);

extern node_t *multiply(node_t *self);

extern node_t *divide(node_t *self);

extern node_t *less_than(node_t *self);

extern node_t *getRandCharValue(node_t *self);

extern node_t* print(node_t *self);

extern node_t* print_int(node_t *self);

extern node_t *assignment(node_t *self);

extern node_t *str_assignment(node_t *self);

extern node_t *str_concat(node_t *self);

extern node_t *if_statement(node_t *self);

extern node_t *while_loop(node_t *self);

extern node_t *do_statements(node_t *self);

extern int evaluate(node_t *self);
#endif //NODE_H
