// tipos de datos y constantes

#define INT 1
#define FLOAT 2
#define STR 3
#define CAMPO 4

// estructura donde se almacena cada empleado
typedef struct{
	int idEmpleado;
	char *nombre;
	char *puesto;
	char *correo;
	char *anho;
	float salario;
} empleado;

//union que se usa par almacenar los valores de los campos en
//la condicion del where
typedef union {
	int entero;
	float real;
	char *string;
}Valor;

// Operando, tipovalor-> 1 int, 2 real, 3 string, 4 campoop
typedef struct{
	int tipovalor;	
	Valor valor;
} Operando;

// Componentes de la condicion
typedef struct{
	int tipovalor;
	// donde esta el campo si lo hay: 0-> no hay ningun campo
	// 1-> campo en el primer operando, 2-> campo en el segundo operando
	// 3-> campo en los dos operandos
	int campo;
	Operando op1;
	char operador;
	Operando op2;
} Condicion;
