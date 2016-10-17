//File: node.c
//Author: Jonathan Carpenter
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "node.h"

class_t *makeClass(char* name, class_t *parent){
  class_t *c = (class_t *)calloc(1, sizeof(class_t));
  c->name = strdup(name);
  c->parent = parent;

  ivars_t *ivars = (ivars_t *)calloc(1, sizeof(ivars_t));
  ivars->num_vars = 0;

  svars_t *svars = (svars_t *)calloc(1, sizeof(svars_t));
  svars->num_vars = 0;

  c->ivars = ivars;
  c->svars = svars;

  return c;
}

void addIntVar(class_t *c, char *var, int value){

  ivars_t *ivars = c->ivars;
  int index = ivars->num_vars;
  ivars->names[index] = strdup(var);
  ivars->values[index] = value;
  ivars->num_vars = index + 1;
}

void addStrVar(class_t *c, char *var, char *value){
  svars_t *svars = c->svars;
  int index = svars->num_vars;
  svars->names[index] = strdup(var);
  svars->values[index] = strdup(value);
  svars->num_vars = index + 1;
}  

int getIntVar(class_t *c, char *name){
  ivars_t *ivars = c->ivars;
  int index = 0;
  for(; index < ivars->num_vars; index++){
    if(!strcmp(name, ivars->names[index])){
      return ivars->values[index];
    }
  }
  if(c->parent != NULL) {
    getIntVar(c->parent, name);
  }
  else{
    printf("Could not find int var!\n");
    exit(2);
  }
}

char *getStrVar(class_t *c, char *name){
  svars_t *svars = c->svars;
  int index = 0;
  for(; index < svars->num_vars; index++){
    if(!strcmp(name, svars->names[index])){
      return svars->values[index];
    }
  }
  if(c->parent != NULL) {
    getStrVar(c->parent, name);
  }
  else{
    printf("Could not find String!\n");
    exit(2);
  }
}

node_t *makeClassNode(char *name, class_t *parent){
  node_t *node = (node_t *)calloc(1, sizeof(node_t));
  node->obj = makeClass(name, parent);
  node->fun = getValue;
  return node;
}

node_t *addIntVarNode(node_t* self){
  evaluate(self->left);
  evaluate(self->center);
  evaluate(self->right);
  addIntVar(self->left->obj, self->center->strvalue, self->right->value);
  return self;
}

node_t *addStrVarNode(node_t* self){
  evaluate(self->left);
  evaluate(self->center);
  evaluate(self->right);
  addStrVar(self->left->obj, self->center->strvalue, self->right->strvalue);
  return self;
}

node_t *getStrVarNode(node_t* self){
  evaluate(self->left);
  evaluate(self->right);
  self->strvalue = getStrVar(self->left->obj, self->right->strvalue);
  return self;
}

node_t *getIntVarNode(node_t* self){
  evaluate(self->left);
  evaluate(self->right);
  self->value = getIntVar(self->left->obj, self->right->strvalue);
  return self;
}

node_t *makeNode(node_t *left, node_t *center,  node_t *right, funptr fun) {
  node_t *node = (node_t *)calloc(1, sizeof(node_t));
  node->left = left;
  node->center = center;
  node->right = right;
  node->fun = fun;
  return node;
}

node_t *makeIntNode(int value) {
  node_t *node = (node_t *)calloc(1, sizeof(node_t));
  node->value = value;
  node->fun = getValue;
  return node;
}

node_t *makeStrNode(char *value) {
  node_t *node = (node_t *)calloc(1, sizeof(node_t));
  node->strvalue = value;
  node->fun = getValue;
  return node;
}

node_t *makeRandStrNode() {
  node_t *node = (node_t *)calloc(1, sizeof(node_t));
  node->fun = getRandCharValue;
  return node;
}

node_t *getRandCharValue(node_t *self) {
  self->strvalue = (char *)malloc(1 + sizeof(char));
  self->strvalue[0] = (char)((rand() % 26) + 65);
  self->strvalue[1] = '\0';
  return self;
}

node_t *getValue(node_t *self) {
  return self;
}

node_t *add(node_t *self) {
  //  printf("add\n");
  self->value = evaluate(self->left) + evaluate(self->right);
  return self;
}

node_t *subtract(node_t *self) {
  self->value = evaluate(self->left) - evaluate(self->right);
  return self;
}

node_t *multiply(node_t *self) {
  self->value = evaluate(self->left) * evaluate(self->right);
  return self;
}

node_t *divide(node_t *self) {
  self->value = evaluate(self->left) / evaluate(self->right);
  return self;
}
node_t *less_than(node_t *self) {
  //  printf("less_than\n");
  self->value = (evaluate(self->left) < evaluate(self->right));
  return self;
}

node_t* print(node_t *self) {
  //  printf("print\n");
  evaluate(self->left);
  printf("%s\n", self->left->strvalue);
  return self;
}

node_t* print_int(node_t *self) {
  //  printf("print_int\n");
  evaluate(self->left);
  printf("%d\n", self->left->value);
  return self;
}
node_t *if_statement(node_t *self) {
  if(evaluate(self->left))
    self->value = evaluate(self->center);
  else
    self-> value = evaluate(self->right);
  return self;
}

node_t *while_loop(node_t *self) {
  while(evaluate(self->left)) {
    evaluate(self->right);
  }
  return self;
}

node_t *assignment(node_t *self) {
  //  printf("assign\n");
  self->value = evaluate(self->right);
  self->left->value = self->value;
  return self;
}

node_t *str_assignment(node_t *self) {
  //  printf("str_assign\n");
  evaluate(self->right);
  self->left->strvalue = self->right->strvalue;
  return self;
}

node_t *str_concat(node_t *self) {
  //  printf("str_concat\n");
  evaluate(self->left);
  evaluate(self->right);
  self->strvalue = (char *)malloc(1 + strlen(self->left->strvalue)
		       + strlen(self->right->strvalue));
  strcpy(self->strvalue, self->left->strvalue);
  strcat(self->strvalue, self->right->strvalue);
  return self;
}

node_t *do_statements(node_t *self) {
  //  printf("do_it\n");
  evaluate(self->left);
  evaluate(self->right);
  return self;
}

int evaluate(node_t *self) {
  return (*self->fun)(self)->value;
}
