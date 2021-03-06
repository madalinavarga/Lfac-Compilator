%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

//STRUCTURA ARBORE
enum enum_tip {OP,IDENTIFIER,NUMBER,OTHER,ARRAY_ELEM} ;
struct ast_node{
        
        char* valoare;
        struct ast_node* stanga; 
        struct ast_node* dreapta; 
        enum enum_tip tip;
}; 


//STRUCTURA VARIABILE + FUNCTII + OBIECTE
struct variabile{
      char* tip;
      char* id;
      char* valoare;
      char** val2;
      char* vizibilitate;
      int constante;
      int dimensiune;
}var[100];

struct parametru{
      char* tip;
      char* id;
};

struct functii{
      char* tip_return;
      int nr_parametrii;
      char* id;
      struct parametru parametrii_functie[10];

}functii[100];

struct clase{
        char tip[20];
        int nr_variabile;
        struct variabile class_var[10];
}clase[100];

struct obiecte{
        char* tip_clasa;
        char* id;
        char* vizibilitate;
}obiecte[100];


//DECLARATII FUNCTII + VARIABILE GLOBALE  UTILIZATE
int nr_obiecte=0,index_array=0;
int nr_clase=0;
char empty[]=" ";
struct parametru aux[100],empty_struct[1]={" "," "};
struct parametru aux_apel[100];
int count_v=0,count_f=0,count_aux=0, count_aux_apel=0;
char fisier_variabile[]="symbol_table.txt";
char fisier_functii[]="symbol_table_functions.txt ";


struct ast_node *buildAST(char* val_nod,struct ast_node *stanga, struct ast_node *dreapta,int tip);
int evalAST(struct ast_node *ast);

int variabila_deja_declarata(char* nume,char* vizibilitate);
void declarare_fara_initializare(char* tip,char* nume, int este_const,char* vizibilitate);
void declarare_cu_initializare(char* tip,char* nume,int val,int este_const,char* vizibilitate);
void scrieVariabileFisier();
void scrieFunctiiInFisier();
int get_valoare_dupa_nume(char * nume);
void set_parametrii_functie(char* tip, char* id,struct parametru *aux);
int functie_deja_declarata(char* id,struct parametru *param);
void mesaj_functie_existenta(char msg[]);
void creaza_functie(char* tip, char* id,struct parametru *aux);
void asignare_exista_variabila(char* id , char* viziblitate, char* valoare ,int nr_tip);
void creeaza_clasa(char* tip);
void error_decl(char* nume);
int variabila_class_deja_declarata(char* nume, char* vizibilitate);
void declarare_variabila_class(char* tip, char* nume,char* vizibilitate);
int clasa_deja_definita(char* nume);
void error_decl_clasa(char* nume);
int obiect_deja_definit(char* nume);
int obiect_deja_definit(char* nume);
void error_ne_decl_clasa(char* nume);
void obiect_nou(char* clasa,char* nume, char* vizibilitate);
int membru_clasa(int index_clasa,char* nume);
void error_ne_decl_membru(char* nume);
void asignare_pt_data_membru(char* clasa,char* membru,char* valoare,char* tip_valoare);
void print_variabile(char* mesaj ,char* nume);
void verifica_conditia(int nr1, int nr_conditie, int nr2);
void declarare_cu_initializare_diferit_int(char* tip, char* nume, char* valoare, int este_const, char* vizibilitate);
void declarare_cu_initializare_data_membru(char* tip, char* nume ,char* clasa, char* membru,int este_const, char* vizibilitate);
int verificare_exista_variabila(char* nume);
void asignare_cu_data_membru(char* nume, char* clasa, char* membru);
void error_ne_decl_variabila(char* nume);
void error_nepotrivire();
void declara_vector(char* tip, char* nume, int dimensiune,char* vizibilitate);
void asignare_pt_element_vector(char* nume,int pozitie, char* valoare, char* tip_val);
void asignare_cu_element_vector(char* nume_var,char* nume_vector,int index_elem);
void set_parametrii_apel(char* tip, struct parametru* aux);
void error_ne_decl_functie(char* nume);
char* get_tip_dupa_nume(char* nume);
int functie_deja_declarata_pt_apel(char* id,struct parametru *param);
int get_valoare_vector_dupa_nume(char* nume,int index_elem);
char *citeste_fisier(char *file);
%}

%union
{
    double num;
    char* str;
    int integer;
    float real;
    char* boolean;

    struct expresie{
        struct ast_node *AST;
}expresie;
}


//LEGATURA .l 
%token PRINT CONST DACA ALTFEL PENTRU CAT_TIMP MAIN RETURN EXIT CLASS 
%token GEQ EQ LEQ NEQ ASSIGN OR AND 
%token PLUS MINUS PROD DIV LESS GREATER INCR DECR 
%token<boolean> BOOLEAN
%token<str> CHAR STRING  
%token<real>NR_REAL
%token<integer>NR_INT
%token<str> ID TIP
%type<integer> conditie
%type<expresie> expresie

//SIMBOL DE START
%start s

//PRIORITATI
%right ASSIGN

%left EQ
%left ','
%left GEQ LEQ LESS GREATER

%left PLUS MINUS
%left PROD DIV

%left OR
%left AND
%left NEQ
%left INCR DECR


%%
s: declaratii_globale functii_clase  main_prog {printf("Program corect sintactic\n"); scrieVariabileFisier();scrieFunctiiInFisier();}
 | declaratii_globale main_prog {printf("Program corect sintactic\n"); scrieVariabileFisier();scrieFunctiiInFisier();}
 | functii_clase main_prog {printf("Program corect sintactic\n"); scrieVariabileFisier();scrieFunctiiInFisier();}
 | main_prog {printf("Program corect sintactic\n"); scrieVariabileFisier();scrieFunctiiInFisier();}
 | declaratii_globale {printf("Program corect sintactic\n"); scrieVariabileFisier();scrieFunctiiInFisier();}
 ;
     
//SECTIUNEA 1 - DECLARATII
declaratii_globale :   declaratie_globala ';' { var[count_v-1].vizibilitate=strdup("global");}
	           | declaratii_globale declaratie_globala ';' { var[count_v-1].vizibilitate=strdup("global");}
	           ;
 declaratie_globala:variabila_initializata_global
                   | variabila_declarata_global
                   | print 
                   | asignare_globala
                   ;          
declaratie_locala  : variabila_initializata_local
                   | variabila_declarata_local 
                   | print
                   ;
variabila_initializata_local: CONST TIP ID ASSIGN expresie {if(strcmp($2,"Integer")==0){declarare_cu_initializare($2,$3,evalAST($5.AST),1,"main");}else{error_nepotrivire();}}
                            | CONST TIP ID ASSIGN NR_REAL {char valoare[50]; sprintf(valoare,"%7.2f", $5); if(strcmp($2,"Float")==0) { declarare_cu_initializare_diferit_int($2,$3,valoare,1,"main");}else{error_nepotrivire();}}
                            | CONST TIP ID ASSIGN STRING {if(strcmp($2,"String")==0) { declarare_cu_initializare_diferit_int($2,$3,$5,1,"main");}else{error_nepotrivire();}}
                            | CONST TIP ID ASSIGN ID '.' ID {declarare_cu_initializare_data_membru($2,$3, $5,$7,1,"main");}
                            | TIP ID ASSIGN expresie {if(strcmp($1,"Integer")==0){declarare_cu_initializare($1,$2,evalAST($4.AST),0,"main");} else{error_nepotrivire();}}
                            | TIP ID ASSIGN NR_REAL {char valoare[50]; sprintf(valoare,"%7.2f", $4); if(strcmp($1,"Float")==0) { declarare_cu_initializare_diferit_int($1,$2,valoare,0,"main");}else{error_nepotrivire();}}
                            | TIP ID ASSIGN STRING {if(strcmp($1,"String")==0) { declarare_cu_initializare_diferit_int($1,$2,$4,0,"main");}else{error_nepotrivire();}}
                            | TIP ID ASSIGN ID '.' ID {declarare_cu_initializare_data_membru($1,$2, $4,$6,0,"main");}
                            ;
variabila_declarata_local: TIP ID {declarare_fara_initializare($1,$2,0,"main");}
                         | array_loc
                         ;
variabila_initializata_global: CONST TIP ID ASSIGN expresie {if(strcmp($2,"Integer")==0){declarare_cu_initializare($2,$3,evalAST($5.AST),1,"global");}else{error_nepotrivire();}}
                             | CONST TIP ID ASSIGN NR_REAL {char valoare[50]; sprintf(valoare,"%7.2f", $5); if(strcmp($2,"Float")==0) { declarare_cu_initializare_diferit_int($2,$3,valoare,1,"global");}else{error_nepotrivire();}}
                             | CONST TIP ID ASSIGN STRING {if(strcmp($2,"String")==0) { declarare_cu_initializare_diferit_int($2,$3,$5,1,"global");}else{error_nepotrivire();}}
                             | TIP ID ASSIGN expresie {if(strcmp($1,"Integer")==0){declarare_cu_initializare($1,$2,evalAST($4.AST),0,"global");} else{error_nepotrivire();}}
                             | TIP ID ASSIGN NR_REAL {char valoare[50]; sprintf(valoare,"%7.2f", $4); if(strcmp($1,"Float")==0) { declarare_cu_initializare_diferit_int($1,$2,valoare,0,"global");}else{error_nepotrivire();}}
                             | TIP ID ASSIGN STRING {if(strcmp($1,"String")==0) { declarare_cu_initializare_diferit_int($1,$2,$4,0,"global");}else{error_nepotrivire();}}
                             ;
variabila_declarata_global: TIP ID {declarare_fara_initializare($1,$2,0,"global");}
                          | array_glob
                          ;
/*
lista_declaratii : ID
                 | lista_declaratii ',' ID
                 ;
*/
expresie : expresie PLUS expresie                {$$.AST = buildAST("+", $1.AST, $3.AST, OP); }
         | expresie MINUS expresie               {$$.AST = buildAST("-", $1.AST, $3.AST, OP) ;}
         | expresie PROD expresie                {$$.AST = buildAST("*", $1.AST, $3.AST, OP) ;}
         | expresie DIV expresie                 {$$.AST = buildAST("/", $1.AST, $3.AST, OP) ;}
         |'(' expresie ')'                       {char str_val[50]; snprintf(str_val,50,"%d",evalAST($2.AST)); $$.AST = buildAST(str_val, NULL, NULL, NUMBER);}
         | ID                                    {int verificare=get_valoare_dupa_nume($1); if(verificare!=-1) {$$.AST = buildAST($1, NULL, NULL, IDENTIFIER);} else{error_nepotrivire($1);}}
         | NR_INT                                {char str_val[50]; snprintf(str_val,50,"%d",$1); $$.AST = buildAST(str_val, NULL, NULL, NUMBER);}
         | ID '[' NR_INT ']'  {index_array=$3; $$.AST=buildAST($1,NULL,NULL,ARRAY_ELEM);}
         | ID  '(' ')' {if(functie_deja_declarata($1,empty_struct)==0){count_aux_apel=0; error_ne_decl_functie($1);} else{count_aux_apel=0; char* tip_apel; tip_apel=strdup(get_tip_dupa_nume($1));  if(strcmp(tip_apel,"Integer")==0){$$.AST=buildAST("0",NULL,NULL,OTHER);}else{error_nepotrivire();}}} 
         | ID '(' lista_apel')' {int verific=functie_deja_declarata_pt_apel($1,aux_apel);  if(verific==0){count_aux_apel=0; error_ne_decl_functie($1);} else{count_aux_apel=0; char* tip_apel; tip_apel=strdup(get_tip_dupa_nume($1)); if(strcmp(tip_apel,"Integer")==0){$$.AST=buildAST("0",NULL,NULL,OTHER);}else{error_nepotrivire();}}}
         ;

array_glob : TIP ID '[' NR_INT ']' {declara_vector($1,$2,$4,"global");}
      //| TIP ID '[' ']' ASSIGN '{' lista_valori '}'
      ;
array_loc : TIP ID '[' NR_INT ']' {declara_vector($1,$2,$4,"main");}
//dimensiune : '['NR_INT']'
          //| dimensiune '['NR_INT']'
/*        ; 
lista_valori : lista_valori ',' valoare
             | valoare
             ;
valoare :  NR_INT
        | NR_REAL
        | STRING
        | CHAR
        ;
*/
print:  PRINT '(' STRING ',' expresie ')'   {printf("%s %d\n",$3,evalAST($5.AST));}
     |  PRINT '(' STRING ')'  {printf("%s\n",$3);}
     |  PRINT '(' STRING ',' '&'ID ')'  {print_variabile($3,$6);}
     ;
asignare_globala : ID ASSIGN expresie   {char count_str[]="global"; char str_valoare[50]; snprintf(str_valoare,50,"%d",evalAST($3.AST)); asignare_exista_variabila($1,count_str,str_valoare,0);}
                 | ID ASSIGN NR_REAL  {char count_str[]="global"; char str_valoare[50]; snprintf(str_valoare,50,"%f",$3); asignare_exista_variabila($1,count_str,str_valoare,1);}
                 | ID ASSIGN STRING    {char count_str[]="global"; asignare_exista_variabila($1,count_str,$3,2);}
                 | ID ASSIGN CHAR     {char count_str[]="global"; asignare_exista_variabila($1,count_str,$3,3);}
                 ;

//SECTIUNE 2 FUNCTII SI CLASE 
functii_clase : functii_clase class_definitie
                | functii_declaratie 
                | class_definitie
                | functii_clase functii_declaratie
                ;

class_definitie : CLASS ID  '{' class_declaratii '}' ';' {if(clasa_deja_definita($2)==-1){
                                                                creeaza_clasa($2);
                                                                }
                                                        else{
                                                               error_decl_clasa($2); 
                                                        }
                                                }
                ;
                ;
class_declaratii: class_declaratie
                | class_declaratii class_declaratie
                ;
class_declaratie: TIP ID ';' { if(variabila_class_deja_declarata($2,"class")==-1){
                                   declarare_variabila_class($1,$2,"class");   
                                }
                                else{
                                        error_decl($2);
                                }
                        }
                ;

functii_declaratie : TIP ID '(' lista_param ')' '{' cod_functii '}' { if(functie_deja_declarata($2,aux)==0){ creaza_functie($1,$2,aux);} else {count_aux=0;mesaj_functie_existenta($2); } }
                   | TIP ID '(' ')' '{' cod_functii '}' {if(functie_deja_declarata($2,empty_struct)==0){ creaza_functie($1,$2,empty_struct);} else {count_aux=0;mesaj_functie_existenta($2); } }
                   ;
cod_functii: cod_functii cod_f
           | cod_f
           ;
cod_f : declaratie_locala ';' {char count_str[100]; snprintf(count_str,100,"functie-%d",count_f); var[count_v-1].vizibilitate=strdup(count_str);}
            | asignare_functie 
            | bucle 
            | print 
            | interogari
            ;

lista_param : param
            | lista_param ','  param 
            ;
param: TIP ID { set_parametrii_functie($1,$2,aux);}
     ;
asignare_functie: ID ASSIGN expresie ';' {char count_str[100]; snprintf(count_str,100,"functie-%d",count_f); char str_valoare[50]; snprintf(str_valoare,50,"%d",evalAST($3.AST)); asignare_exista_variabila($1,count_str,str_valoare,0);}
                | ID ASSIGN NR_REAL ';'  {char count_str[100]; snprintf(count_str,100,"functie-%d",count_f); char str_valoare[50]; snprintf(str_valoare,50,"%f",$3); asignare_exista_variabila($1,count_str,str_valoare,1);}
                | ID ASSIGN STRING ';'   {char count_str[100]; snprintf(count_str,100,"functie-%d",count_f); asignare_exista_variabila($1,count_str,$3,2);}
                | ID ASSIGN CHAR ';'     {char count_str[100]; snprintf(count_str,100,"functie-%d",count_f); asignare_exista_variabila($1,count_str,$3,3);}
                ;



//SECTIUNE 3 MAIN 
main_prog :
           MAIN '('  ')' acolade
          ;
acolade : '{' '}'
        | '{' cod_bloc '}'
        ;
cod_bloc : cod_bloc cod
         | cod
         ;
cod: interogari
   | bucle
   | declaratie_locala ';' {var[count_v-1].vizibilitate=strdup("main");}
   | statement ';'
   | asignare_main ';'
   | apel_functie ';'
   | functii_declaratie 
   | clasa_noua ';'
   ;
/*
clasa_noua : ID ID { if(clasa_definita($1,"class")!=-1){

                                obiect_nou($1,$2,"main");
                        }

                }
           ;
*/
clasa_noua : ID ID { if(clasa_deja_definita($1)!=-1){
                                if(obiect_deja_definit($2)==-1){
                                        obiect_nou($1,$2,"main");
                                }
                                else{
                                        error_decl($2);
                                }
                                
                        }
                        else{
                               error_ne_decl_clasa($1); 
                        }

                }
           ;

asignare_main :   ID ASSIGN expresie   {char count_str[]="main"; char str_valoare[50]; snprintf(str_valoare,50,"%d",evalAST($3.AST)); asignare_exista_variabila($1,count_str,str_valoare,0);}
                | ID ASSIGN NR_REAL   {char count_str[]="main"; char str_valoare[50]; snprintf(str_valoare,50,"%f",$3); asignare_exista_variabila($1,count_str,str_valoare,1);}
                | ID ASSIGN STRING    {char count_str[]="main"; asignare_exista_variabila($1,count_str,$3,2);}
                | ID ASSIGN CHAR      {char count_str[]="main"; asignare_exista_variabila($1,count_str,$3,3);}
                | ID '.' ID ASSIGN NR_REAL {char valoare[50];  snprintf(valoare,50,"%7.2f",$5);  asignare_pt_data_membru($1,$3,valoare,"Float");}
                | ID '.' ID ASSIGN expresie { char valoare[50]; sprintf(valoare,"%d",evalAST($5.AST));  asignare_pt_data_membru($1,$3,valoare,"Integer");}
                | ID '.' ID ASSIGN STRING { asignare_pt_data_membru($1,$3,$5,"String");}
                | ID '.' ID ASSIGN BOOLEAN {asignare_pt_data_membru($1,$3,$5,"Bool");}
                | ID ASSIGN ID '.' ID {asignare_cu_data_membru($1,$3,$5);}
                | ID '[' NR_INT ']' ASSIGN expresie { char valoare[50]; sprintf(valoare,"%d",evalAST($6.AST)); asignare_pt_element_vector($1,$3,valoare, "Integer");}
                | ID '[' NR_INT ']' ASSIGN NR_REAL {char valoare[50]; sprintf(valoare,"%7.2f",$6); asignare_pt_element_vector($1,$3,valoare, "Float");}
                | ID '[' NR_INT ']' ASSIGN STRING { asignare_pt_element_vector($1,$3,$6, "String");}
                //| ID ASSIGN ID '['NR_INT']' {asignare_cu_element_vector($1,$3,$5);}
                ;

apel_functie :  ID '(' ')'    {if(functie_deja_declarata_pt_apel($1,empty_struct)==0){count_aux_apel=0; error_ne_decl_functie($1);}else{count_aux_apel=0; }}          
             | ID '(' lista_apel')' {int verific=functie_deja_declarata_pt_apel($1,aux_apel); if(verific==0){count_aux_apel=0; error_ne_decl_functie($1);}else{count_aux_apel=0; }}
             ;
lista_apel: param_apel
          | lista_apel',' param_apel
          ;
param_apel : expresie { set_parametrii_apel("Integer",aux_apel);}
           | NR_REAL {set_parametrii_apel("Float",aux_apel);}
          // | ID  '(' ')' {if(functie_deja_declarata($1,empty_struct)==0){count_aux_apel=0; error_ne_decl_functie($1);} else{count_aux_apel=0; char* tip_apel; tip_apel=strdup(get_tip_dupa_nume($1));  set_parametrii_apel(tip_apel,aux_apel);}} 
          // | ID '(' lista_apel')' {int verific=functie_deja_declarata_pt_apel($1,aux_apel); if(verific==0){count_aux_apel=0; error_ne_decl_functie($1);} else{count_aux_apel=0; char* tip_apel; tip_apel=strdup(get_tip_dupa_nume($1));  set_parametrii_apel(tip_apel,aux_apel);}}
           ;

statement: ID INCR {int verificare=verificare_exista_variabila($1); if(verificare==-1){error_ne_decl_variabila($1);}}
         //| apel_functie
         | ID DECR {int verificare=verificare_exista_variabila($1); if(verificare==-1){error_ne_decl_variabila($1);}}
         | INCR ID {int verificare=verificare_exista_variabila($2); if(verificare==-1){error_ne_decl_variabila($2);}}
         | DECR ID {int verificare=verificare_exista_variabila($2); if(verificare==-1){error_ne_decl_variabila($2);}}
         ;
    
interogari: DACA '(' conditie_if')' '{' cod_bloc '}'
          | DACA '(' conditie_if ')' '{' cod_bloc '}' ALTFEL '{' cod_bloc '}'
          ;

conditie_if : conditie_if LESS conditie_if
            | conditie_if GREATER conditie_if
            | conditie_if LEQ conditie_if
            | conditie_if GEQ conditie_if
            | conditie_if EQ conditie_if
            | conditie_if NEQ conditie_if
            | conditie_if OR conditie_if
            | conditie_if AND conditie_if
            | conditie_if PLUS conditie_if
            | conditie_if MINUS conditie_if
            | conditie_if PROD conditie_if
            | conditie_if DIV conditie_if
            | ID {if(verificare_exista_variabila($1)==-1) error_ne_decl_variabila($1); }
            | ID '(' ')'    {if(functie_deja_declarata_pt_apel($1,empty_struct)==0){count_aux_apel=0; error_ne_decl_functie($1);}else{count_aux_apel=0; }}   
            | ID '(' lista_apel')' {int verific=functie_deja_declarata_pt_apel($1,aux_apel); if(verific==0){count_aux_apel=0; error_ne_decl_functie($1);}else{count_aux_apel=0; }}
            | NR_INT
            | '(' conditie_if ')'
            ;

			  
conditie : expresie LESS expresie    {verifica_conditia(evalAST($1.AST),1,evalAST($3.AST));}	 			
         | expresie GREATER expresie {verifica_conditia(evalAST($1.AST),2,evalAST($3.AST));}				
	 | expresie LEQ expresie     {verifica_conditia(evalAST($1.AST),3,evalAST($3.AST));}			
	 | expresie GEQ expresie     {verifica_conditia(evalAST($1.AST),4,evalAST($3.AST));}			
	 | expresie EQ expresie      {verifica_conditia(evalAST($1.AST),5,evalAST($3.AST));}
         | expresie NEQ expresie     {verifica_conditia(evalAST($1.AST),6,evalAST($3.AST));}
         | expresie	             {verifica_conditia(0,7,0);}	
	 ;
bucle:  functie_for
     | functie_while
     ;
functie_while : CAT_TIMP '(' conditie')' '{' cod_bloc '}'
              ;
functie_for: PENTRU '('for_list')' '{' cod_bloc '}'
           ;
for_list: asignare_main ';' conditie ';' statement
        ;

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 



int variabila_deja_declarata(char* nume,char* vizibilitate){
        //parcurgere structura cu variabila si verificare
        for (int i = 0; i < count_v; i++)
        {
                if (strcmp(var[i].id, nume) == 0 && strcmp(var[i].vizibilitate, vizibilitate) == 0 ) 
                { 
                return i;
                }
        }
        return -1;
}

void declarare_fara_initializare(char* tip,char* nume, int este_const,char* vizibilitate){
        if(variabila_deja_declarata(nume,vizibilitate)!=-1){
                char error_msg[250];
                sprintf(error_msg, "Variabila %s este deja declarata. Eroare ", nume);
                yyerror(error_msg);
                exit(0);
        }
        if(este_const==1){
                char error_msg[250];
                sprintf(error_msg, "Variabila constanta %s nu poate fi declarata fara initializare", nume);
                yyerror(error_msg);
                exit(0);
        }
        var[count_v].tip=strdup(tip);
        var[count_v].id=strdup(nume);
        var[count_v].constante=0;
        var[count_v].vizibilitate=strdup(vizibilitate);
        //var[count_v].valoare=(char*)malloc(4);
        //strcpy(var[count_v].valoare,"0");
        count_v++;
}
void declarare_cu_initializare(char* tip,char* nume,int val,int este_const,char* vizibilitate){
        //verificare daca exista 
        if(variabila_deja_declarata(nume,vizibilitate)!=-1){
                char error_msg[250];
                sprintf(error_msg, "Variabila %s este deja declarata", nume);
                yyerror(error_msg);
                exit(0);
        }
        //seteaza valorile si incrementeaza
        var[count_v].tip=strdup(tip);
        var[count_v].id=strdup(nume);
        char valoare[50];
        snprintf(valoare,50,"%d",val);
        var[count_v].valoare=strdup(valoare);
        var[count_v].constante=este_const;
        var[count_v].vizibilitate=strdup(vizibilitate);
        count_v++;
      
}

int get_valoare_dupa_nume(char * nume)
{ 
       
        int gasit=0;
         for (int i = 0; i < count_v; i++)
         {
                //daca gaseste valoare si este integer => o returneaza
                 if(strcmp(var[i].id,nume)==0 && strcmp(var[i].tip,"Integer")==0){
                 gasit++;
                 int valoare=atoi(var[i].valoare);
                 return valoare;
                 }
                 else{ //gaseste valoare si nu este integer=> eroare 
                         if(strcmp(var[i].id,nume)==0 && strcmp(var[i].tip,"Integer")!=0){
                                char error_msg[250];
                                sprintf(error_msg, "Expresie poate fi doar Integer");
                                yyerror(error_msg);
                                exit(0);
                         }
                 }
         }

         if(gasit==0) //daca nu exista variabila => eroare 
         {
                char error_msg[250];
                sprintf(error_msg, "Variabila %s nu exista", nume);
                yyerror(error_msg);
                exit(0);
         }

}
void print_variabile(char* mesaj ,char* nume)
{
        
        char* ptr=nume;
        int gasit=0;
        for (int i = 0; i < count_v; i++)
         {
                 //cautare dupa nume
                 if(strcmp(var[i].id,nume)==0){
                         gasit++;
                         printf("%s: %s\n",mesaj,var[i].valoare);
                 }
         }
           if(gasit==0) 
         {
                char error_msg[250];
                sprintf(error_msg, "Variabila nu exista");
                yyerror(error_msg);
                exit(0);
         }

}

void creaza_functie(char* tip, char* id,struct parametru *aux)
{       //mutam valorile din structura auxiliara in functie 
        functii[count_f].nr_parametrii=count_aux;
        functii[count_f].tip_return=strdup(tip);
        functii[count_f].id=strdup(id);
        for(int i =0;i<count_aux;i++) // setam parametrii
        {
                functii[count_f].parametrii_functie[i].id=strdup(aux[i].id);
                functii[count_f].parametrii_functie[i].tip=strdup(aux[i].tip);
        }
        count_f++; // incrementare nr functiilor
        count_aux=0; // resetare aux

}
void asignare_exista_variabila(char* id , char* viziblitate ,char* valoare, int nr_tip)
{       //verificam daca exista variabila 
        int index=verificare_exista_variabila(id);
        if(index==-1){
                error_ne_decl_variabila(id);
        }
        else{
                if(var[index].dimensiune>0){ error_ne_decl_variabila(id);}
                else{
                if(var[index].constante==1){
                        char error_msg[250];
                        sprintf(error_msg, "Variabila %s este const", id);
                        yyerror(error_msg);
                        exit(0);
                }
         for (int i = 0; i < count_v; i++){
                if(strcmp(var[i].id,id)==0){ // acelasi nume si global => pot folosi oriunde 
                  if(strcmp(var[i].vizibilitate,"global")==0) var[i].valoare=strdup(valoare);
                  else
                   if(strcmp(var[i].vizibilitate,viziblitate)==0) 
                   {
                           if(nr_tip==0 && strcmp(var[i].tip,"Integer")==0) { // int , expresie deja verificat
                            var[i].valoare=strdup(valoare);
                           }else
                           if(nr_tip==1 && strcmp(var[i].tip,"Float")==0)
                           {
                                   var[i].valoare=strdup(valoare);
               
                           }else
                           if(nr_tip==2 && strcmp(var[i].tip,"String")==0){
                                   var[i].valoare=strdup(valoare);
                           }else
                           if(nr_tip==3 && strcmp(var[i].tip,"Char")==0)
                           {
                                   var[i].valoare=strdup(valoare);
                           }else
                           {
                                
                                char error_msg[250];
                                sprintf(error_msg, "Nepotrivire tipuri");
                                yyerror(error_msg);
                                exit(0);
                           }
                   }
                }
                   
         }
        }
        }

       
}

void set_parametrii_functie(char* tip, char* id,struct parametru *aux)
{
       
        aux[count_aux].id=(char*)malloc(strlen(id));
        strcpy(aux[count_aux].id,id);
        aux[count_aux].tip=(char*)malloc(strlen(tip));
        strcpy(aux[count_aux].tip,tip);
        count_aux++;    
}

void set_parametrii_apel(char* tip, struct parametru *aux){
        
        aux[count_aux_apel].tip=(char*)malloc(strlen(tip));
        strcpy(aux[count_aux_apel].tip,tip);
        count_aux_apel++; 
}

char* get_tip_dupa_nume(char* nume){
        for(int i=0; i<count_f;i++){
              if(strcmp(functii[i].id,nume)==0){
                      return functii[i].tip_return;
              }  
        }
}




int functie_deja_declarata(char* id,struct parametru *param)
{       
        
        int size_param=count_aux;
        for(int i=0; i<count_f;i++){
                if(strcmp(functii[i].id,id)==0){//daca gasesc o functie cu acelasi nume
                        if(functii[i].nr_parametrii==size_param){//acelasi numar de parametri
                                int gasit=0;
                                for(int j=0;j<functii[i].nr_parametrii; j++){ //verific tipul fiecarui parametru
                                        if(strcmp(functii[i].parametrii_functie[j].tip,param[j].tip)==0){
                                                gasit++;
                                        }
                                }
                                if(gasit==functii[i].nr_parametrii){
                                        return -1;
                                }
                        }
                }
        }

        return 0;

       
        /*
        for(int i=0;i<count_f;i++)
        {
               //overloading 
               //nume + tip identic => parametrii diferiti
                if(strcmp(functii[i].tip_return,tip)==0 && strcmp(functii[i].id,id)==0){
                        //verific nr parametrii egal 
                        
                        if(functii[i].nr_parametrii==size_param)
                        return 1;
                        } 
                else  
                   if(strcmp(functii[i].id,id)==0){  // nume identic dar parametrii diferiti ok 
                        //verific nr parametrii egal 
                        if(functii[i].nr_parametrii!=size_param)
                          return 0;
                        else // nr parametrii egali => nume diferit la cel putin 1
                           for(int j=0;j<functii[i].nr_parametrii;j++) //pentru fiecare parametru 
                                if(strcmp(param[j].id,functii[i].parametrii_functie[j].id)==0) gasit++;
                   }
                                      
                
        }
     
        if(gasit==count_aux) return 1;
        return 0;
        */

}

int functie_deja_declarata_pt_apel(char* id,struct parametru *param){
        int size_param=count_aux_apel;
        for(int i=0; i<count_f;i++){
                if(strcmp(functii[i].id,id)==0){//daca gasesc o functie cu acelasi nume
                        if(functii[i].nr_parametrii==size_param){//acelasi numar de parametri
                                int gasit=0;
                                for(int j=0;j<functii[i].nr_parametrii; j++){ //verific tipul fiecarui parametru
                                        if(strcmp(functii[i].parametrii_functie[j].tip,param[j].tip)==0){
                                                gasit++;
                                        }
                                }
                                if(gasit==functii[i].nr_parametrii){
                                        return -1;
                                }
                        }
                }
        }

        return 0;
}


void mesaj_functie_existenta(char msg[]){
     char error_msg[250];
     sprintf(error_msg, "functia %s este deja declarata.Eroare ", msg);
     yyerror(error_msg);
     exit(0);
}

void verifica_conditia(int nr1, int nr_conditie, int nr2)
{
       int variabila=0;
        switch (nr_conditie) {
        case 1:
            if(nr1<nr2) {printf("Conditie indeplinita\n"); variabila++;}
            else printf("Conditie neindeplinita\n");
            break;
        case 2:
            if(nr1>nr2) printf("Conditie indeplinita\n");
            else printf("Conditie neindeplinita\n");
            break;
        case 3:
            if(nr1<=nr2) printf("Conditie indeplinita\n");
            else printf("Conditie neindeplinita\n");
            break;
        case 4:
            if(nr1>=nr2) printf("Conditie indeplinita\n");
            else printf("Conditie neindeplinita\n");
            break;
        case 5:
            if(nr1==nr2) printf("Conditie indeplinita\n");
            else printf("Conditie neindeplinita\n");
            break;
        case 6:
            if(nr1!=nr2) printf("Conditie indeplinita\n");
            else printf("Conditie neindeplinita\n");
            break;
        case 7:
            printf("Bucla Infinita\n");
            break;
        default:
              printf("Nu cunosc conditia\n");
                exit(0);
        }
}


void creeaza_clasa(char* tip){
        strcpy(clase[nr_clase].tip,tip);
        clase[nr_clase].nr_variabile=0;
        nr_clase++;
}

void error_ne_decl_functie(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Functia %s nu este declarata", nume);
        yyerror(error_msg); 
        exit(0);
}

void error_decl(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Variabila %s este deja declarata", nume);
        yyerror(error_msg); 
        exit(0);
       
        
}

void error_decl_clasa(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Clasa %s este deja declarata", nume);
        yyerror(error_msg); 
        exit(0);
}

void error_ne_decl_clasa(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Clasa %s nu a fost definita", nume);
        yyerror(error_msg);
        exit(0);
}

void error_ne_decl_membru(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Membrul %s nu a fost definit", nume);
        yyerror(error_msg);
        exit(0);
}

void error_ne_decl_variabila(char* nume){
        char error_msg[250];
        sprintf(error_msg, "Variabila %s nu a fost declarata", nume);
        yyerror(error_msg);
        exit(0);
}

void error_nepotrivire(){
        char error_msg[250];
        sprintf(error_msg, "Nepotrivire tipuri");
        yyerror(error_msg);
        exit(0);
}

int variabila_class_deja_declarata(char* nume,char* vizibilitate){
        for(int i=0;i<clase[nr_clase-1].nr_variabile;i++){
                if(strcmp(nume, clase[nr_clase-1].class_var[i].id)==0)
                        return i;
        }
        return -1;
}

void declarare_variabila_class(char* tip, char* nume,char* vizibilitate){
        //clase[nr_clase].nr_variabile++;
        clase[nr_clase].class_var[clase[nr_clase].nr_variabile].tip=strdup(tip);
        clase[nr_clase].class_var[clase[nr_clase].nr_variabile].id=strdup(nume);
        char buf[20];
        sprintf(buf,"%s-%d",vizibilitate,nr_clase);
        declarare_fara_initializare(tip,nume, 0, buf);
        clase[nr_clase].nr_variabile++;
}

int clasa_deja_definita(char* nume){
        for(int i=0;i<nr_clase;i++){
                if(strcmp(clase[i].tip,nume)==0){
                        return i;
                }
        }
        return -1;
}

int obiect_deja_definit(char* nume){
        for(int i=0;i<nr_obiecte;i++){
                if(strcmp(obiecte[i].id,nume)==0){
                        return i;
                }
        }
        return -1;
}

void obiect_nou(char* clasa,char* nume, char* vizibilitate){
        obiecte[nr_obiecte].id=strdup(nume);
        obiecte[nr_obiecte].tip_clasa=strdup(clasa);
        obiecte[nr_obiecte].vizibilitate=strdup(vizibilitate);
        declarare_fara_initializare(clasa,nume,0,vizibilitate);
        nr_obiecte++;
}

int membru_clasa(int index_clasa, char* nume){
        //printf("index clasa in care caut: %d, nr variabile: %d\n",index_clasa,clase[index_clasa].nr_variabile);
        for(int i=0;i<10;i++){
                if(strcmp(clase[index_clasa].class_var[i].id,nume)==0){
                        return i;
                }
        }
        return -1;
}

void asignare_pt_data_membru(char* clasa,char* membru,char* valoare,char* tip_valoare){
        int index_clasa=obiect_deja_definit(clasa);
        
        if(index_clasa==-1){
                error_ne_decl_clasa(clasa); 
        }
        else{   
                int index_membru=membru_clasa(index_clasa,membru);
                if(index_membru==-1){
                        error_ne_decl_membru(membru);
                }
                else{
                        char id_variabila[20];
                        bzero(id_variabila,20);
                        strcat(id_variabila,obiecte[index_clasa].id);
                        strcat(id_variabila,".");
                        strcat(id_variabila,membru);
                        if(strcmp(clase[index_clasa].class_var[index_membru].tip,tip_valoare)==0){
                               if(strcmp(tip_valoare,"Integer")==0){
                                        int val=atoi(valoare);
                                        int index=variabila_deja_declarata(id_variabila,"main");
                                        if(index==-1){
                                                declarare_cu_initializare(tip_valoare,id_variabila,val,0,"main");
                                        }
                                        else{
                                                var[index].valoare=strdup(valoare);
                                                //clase[index_clasa].class_var[index_membru].valoare=strdup(valoare);
                                        }
                                }
                                else if(strcmp(tip_valoare,"Float")==0){
                                        //float val=atof(valoare);
                                        int index=variabila_deja_declarata(id_variabila,"main");
                                        if(index==-1){
                                                declarare_cu_initializare_diferit_int(tip_valoare,id_variabila,valoare,0,"main");
                                        }
                                        else{
                                               var[index].valoare=strdup(valoare);  
                                        }
                                }
                                else if(strcmp(tip_valoare,"String")==0){
                                        int index=variabila_deja_declarata(id_variabila,"main");
                                        if(index==-1){
                                                declarare_cu_initializare_diferit_int(tip_valoare,id_variabila,valoare,0,"main");
                                        }
                                        else{
                                               var[index].valoare=strdup(valoare);  
                                        }
                                }
                                else if(strcmp(tip_valoare,"Bool")==0){
                                        printf("am gasit bool\n");
                                        int index=variabila_deja_declarata(id_variabila,"main");
                                        if(index==-1){
                                                declarare_cu_initializare_diferit_int(tip_valoare,id_variabila,valoare,0,"main");
                                        }
                                        else{
                                               var[index].valoare=strdup(valoare);  
                                        }
                                }
                        }
                        else{
                                char error_msg[250];
                                sprintf(error_msg, "Nepotrivire tipuri");
                                yyerror(error_msg);
                                exit(0);
                        }
                }
        }
}

void declarare_cu_initializare_diferit_int(char* tip, char* nume, char* valoare, int este_const, char* vizibilitate){
        if(variabila_deja_declarata(nume,vizibilitate)!=-1){
                char error_msg[250];
                sprintf(error_msg, "Variabila %s este deja declarata", nume);
                yyerror(error_msg);
                exit(0);
        }
        //seteaza valorile si incrementeaza
        var[count_v].tip=strdup(tip);
        var[count_v].id=strdup(nume);
        var[count_v].valoare=strdup(valoare);
        var[count_v].constante=este_const;
        var[count_v].vizibilitate=strdup(vizibilitate);
        count_v++;
}

void declarare_cu_initializare_data_membru(char* tip, char* nume ,char* clasa, char* membru,int este_const, char* vizibilitate){
        char id_data_membru[20];
        bzero(id_data_membru,20);
        strcat(id_data_membru,clasa);
        strcat(id_data_membru,".");
        strcat(id_data_membru,membru);
        int index=verificare_exista_variabila(id_data_membru);
        if(index==-1){
                char error_msg[250];
                sprintf(error_msg, "Variabila %s nu este declarata", id_data_membru);
                yyerror(error_msg);
                exit(0);  
        }
        else{
                if(strcmp(tip,var[index].tip)==0){
                        declarare_cu_initializare_diferit_int(tip,nume,var[index].valoare,este_const,vizibilitate);
                }
                else{
                       char error_msg[250];
                        strcat(error_msg, "Nepotrivire tipuri");
                        yyerror(error_msg);
                        exit(0); 
                }
        }
}

int verificare_exista_variabila(char* nume){
        for (int i = 0; i < count_v; i++){
               if(strcmp(var[i].id,nume)==0)
               {
                       return i;
               } 
        }
        return -1;
}

void asignare_cu_data_membru(char* nume, char* clasa, char* membru){
        char id_data_membru[20];
        bzero(id_data_membru,20);
        strcat(id_data_membru,clasa);
        strcat(id_data_membru,".");
        strcat(id_data_membru,membru);

        int index_variabila=verificare_exista_variabila(nume);
        if(index_variabila==-1){ 
                char error_msg[250];
                sprintf(error_msg, "Variabila %s nu este declarata", nume);
                yyerror(error_msg);
                exit(0);
        }
        else{
                int index_membru=verificare_exista_variabila(id_data_membru);
                if(index_membru==-1){
                       char error_msg[250];
                        sprintf(error_msg, "Variabila %s nu este declarata", nume);
                        yyerror(error_msg);
                        exit(0); 
                }
                else{
                        if(strcmp(var[index_membru].tip,var[index_variabila].tip)==0){
                               var[index_variabila].valoare=strdup(var[index_membru].valoare); 
                        }
                        else{
                                char error_msg[250];
                                strcat(error_msg, "Nepotrivire tipuri");
                                yyerror(error_msg);
                                exit(0);  
                        }
                }
        }
}

void declara_vector(char* tip, char* nume, int dimensiune,char* vizibilitate){
        int index=verificare_exista_variabila(nume);
        if(index!=-1){
                char error_msg[250];
                strcat(error_msg, "Vector deja declarat");
                yyerror(error_msg);
                exit(0);  
        }
        else{   
                var[count_v].tip=strdup(tip);
                var[count_v].id=strdup(nume);
                var[count_v].constante=0;
                var[count_v].vizibilitate=strdup(vizibilitate);
                var[count_v].val2=(char**)malloc(dimensiune * sizeof(char*));
                for(int j=0;j<dimensiune;j++){
                        var[count_v].val2[j]=strdup("0");
                }
                var[count_v].dimensiune=dimensiune;
                count_v++;  
        }
}

void asignare_pt_element_vector(char* nume,int pozitie, char* valoare, char* tip_val){
        int index=verificare_exista_variabila(nume);
        if(index==-1){
                char error_msg[250];
                strcat(error_msg, "Vector  nedeclarat");
                yyerror(error_msg);
                exit(0);  
        }
        else{
                if(strcmp(var[index].tip,tip_val)==0){
                        if(pozitie>=0 && pozitie<var[index].dimensiune){
                             var[index].val2[pozitie]=strdup(valoare);   
                        }
                        else{
                              char error_msg[250];
                                bzero(error_msg,250);
                                strcat(error_msg, "Index invalid");
                                yyerror(error_msg);
                                exit(0);    
                        }
                }
                else{
                        char error_msg[250];
                        strcat(error_msg, "Nepotrivire tipuri");
                        yyerror(error_msg);
                        exit(0); 
                }
        }
}

void asignare_cu_element_vector(char* nume_var,char* nume_vector,int index_elem){
        int index_variabila=verificare_exista_variabila(nume_var);

        if(index_variabila==-1){
                error_ne_decl_variabila(nume_var);
        }
        else{
              int index_vector=verificare_exista_variabila(nume_vector); 
              if(index_vector==-1){
                      error_ne_decl_variabila(nume_vector);
              }
              else{
                      if(index_elem>=var[index_vector].dimensiune || index_elem<0){
                        char error_msg[250];
                        bzero(error_msg,250);
                        strcat(error_msg, "Index invalid");
                        yyerror(error_msg);
                        exit(0);   
                      }
                      else{
                              if(strcmp(var[index_variabila].tip,var[index_vector].tip)!=0){
                                char error_msg[250];
                                bzero(error_msg,250);
                                strcat(error_msg, "Nepotrivire tipuri");
                                yyerror(error_msg);
                                exit(0);  
                              }
                              else{
                                      var[index_variabila].valoare=strdup(var[index_vector].val2[index_elem]);
                              }
                      }
              } 
        }
}

int get_valoare_vector_dupa_nume(char* nume,int index_elem){
        int index_vector=verificare_exista_variabila(nume); 
        if(index_vector==-1){
                error_ne_decl_variabila(nume);
        }
        else{
               if(index_elem>=var[index_vector].dimensiune || index_elem<0){
                        char error_msg[250];
                        bzero(error_msg,250);
                        strcat(error_msg, "Index invalid");
                        yyerror(error_msg);
                        exit(0);   
                } 
                else{
                        if(strcmp(var[index_vector].tip,"Integer")!=0){
                               char error_msg[250];
                                bzero(error_msg,250);
                                strcat(error_msg, "Expresie poate fi doar integer");
                                yyerror(error_msg);
                                exit(0);   
                        }
                        else{
                                return atoi(var[index_vector].val2[index_elem]);
                        }
                }
        }
}
        

void scrieVariabileFisier()
{
      FILE* var_fisier_ptr;
      var_fisier_ptr=fopen(fisier_variabile,"w+"); // dechidere fisier 
      fprintf(var_fisier_ptr,"tip | id  |  valoare | vizibilitate | este_const | dimensiune\n");
      fprintf(var_fisier_ptr,"---------------------------------------------------------\n");
      fprintf(var_fisier_ptr,"\n\nGLOBAL:\n");
      for(int i=0;i<count_v;i++){
              if(strcmp(var[i].vizibilitate,"global")==0)
                fprintf(var_fisier_ptr,"%s  |  %s  |  %s  |  %s  |  %d  |  %d\n", var[i].tip, var[i].id,var[i].valoare, var[i].vizibilitate,var[i].constante,var[i].dimensiune);
              
      }
      fprintf(var_fisier_ptr,"\n\nMAIN:\n");
       for(int i=0;i<count_v;i++){
              if(strcmp(var[i].vizibilitate,"main")==0)
                fprintf(var_fisier_ptr,"%s  |  %s  |  %s  |  %s  |  %d  |  %d\n", var[i].tip, var[i].id,var[i].valoare, var[i].vizibilitate,var[i].constante,var[i].dimensiune);
              
      }

       fprintf(var_fisier_ptr,"\n\nFUNCTII:\n");
       for(int i=0;i<count_v;i++){
              if(strstr(var[i].vizibilitate,"functie"))
                fprintf(var_fisier_ptr,"%s  |  %s  |  %s  |  %s  |  %d  |  %d\n", var[i].tip, var[i].id,var[i].valoare, var[i].vizibilitate,var[i].constante,var[i].dimensiune);
              
      } 

       fprintf(var_fisier_ptr,"\n\nCLASE:\n");
       for(int i=0;i<count_v;i++){
              if(strstr(var[i].vizibilitate,"clas"))
                fprintf(var_fisier_ptr,"%s  |  %s  |  %s  |  %s  |  %d  |  %d\n", var[i].tip, var[i].id,var[i].valoare, var[i].vizibilitate,var[i].constante,var[i].dimensiune);
              
      }
      


      fclose(var_fisier_ptr);
}
void scrieFunctiiInFisier()
{
        //id,tip,parametri,variabile
        FILE* functii_fisier_ptr;
        functii_fisier_ptr=fopen(fisier_functii,"w+");
        fprintf(functii_fisier_ptr,"tip | id | nr_parametrii   |  parametrii \n");
        fprintf(functii_fisier_ptr,"---------------------------------------------------------\n");
        for(int i=0;i<count_f;i++) {
          // afisare tip, nume si nr parametrii
          fprintf(functii_fisier_ptr,"%s | %s | %d: ",functii[i].tip_return,functii[i].id,functii[i].nr_parametrii);

          // afisare parametrii functie
          for(int j=0; j<functii[i].nr_parametrii; j++) {
                  fprintf(functii_fisier_ptr, "%s %s ", functii[i].parametrii_functie[j].tip, functii[i].parametrii_functie[j].id);
          }

          fprintf(functii_fisier_ptr, "\n");
        }


        fclose(functii_fisier_ptr);
}

struct ast_node *buildAST(char* val_nod,struct ast_node *stanga, struct ast_node *dreapta,int tip )
{       //creez nod nou si il returnez
        struct ast_node *nodNou=(struct ast_node*)malloc(sizeof(struct ast_node));
        nodNou->stanga=stanga;
        nodNou->dreapta=dreapta;
        nodNou->valoare=strdup(val_nod);
        nodNou->tip=tip;
        return(nodNou);
}

int evalAST(struct ast_node *ast)
{
        

  if(ast != NULL ){
       if(ast->tip == NUMBER ) return atoi(ast->valoare);
       else 
       if(ast->tip == IDENTIFIER) return get_valoare_dupa_nume(ast->valoare);
       else
       if(ast->tip == ARRAY_ELEM) return get_valoare_vector_dupa_nume(ast->valoare,index_array);
       else{
             
                if(ast->tip == OP)
                {
                        if(strcmp(ast->valoare,"+")==0) return (evalAST(ast->stanga) + evalAST(ast->dreapta));
                        else
                        if(strcmp(ast->valoare,"-")==0) return (evalAST(ast->stanga) - evalAST(ast->dreapta));
                        else
                        if(strcmp(ast->valoare,"*")==0) return (evalAST(ast->stanga) * evalAST(ast->dreapta));
                        else
                        if(strcmp(ast->valoare,"/")==0) return (evalAST(ast->stanga) / evalAST(ast->dreapta));
                }
                else
                {
               // printf("ramura altceva \n");
                return 0;
                }
        }
  }

  return 0;
        
}