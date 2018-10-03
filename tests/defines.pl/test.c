#include <stdio.h>
#include "test.h"

void access(nodes) {

	printf("=============================================\n");
	printf("grid_of    = %d\n", grid_of(node)    );
	printf("size_of    = %d\n", size_of(node)    );
	printf("address_of = %d\n", address_of(node) );
	printf("name_of    = %s\n", name_of(node)    );
	printf("value_of   = %s\n", value_of(node)   );
	printf("is_valid   = %d\n", is_valid(node)   );

}

int main () {

	// Direct use of defines

	printf("---------------------------------------------\n");
	printf("grid_of    = %d\n", grid_of(DEFINES_FIELD)    );
	printf("size_of    = %d\n", size_of(DEFINES_FIELD)    );
	printf("address_of = %d\n", address_of(DEFINES_FIELD) );
	printf("name_of    = %s\n", name_of(DEFINES_FIELD)    );
	printf("value_of   = %s\n", value_of(DEFINES_FIELD)   );
	printf("is_valid   = %d\n", is_valid(DEFINES_FIELD)   );

	printf("---------------------------------------------\n");
	printf("grid_of    = %d\n", grid_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))    );
	printf("size_of    = %d\n", size_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))    );
	printf("address_of = %d\n", address_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2)) );
	printf("name_of    = %s\n", name_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))    );
	printf("value_of   = %s\n", value_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))   );
	printf("is_valid   = %d\n", is_valid(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))   );

	// Indirect use of defines

	access(DEFINES_FIELD);
	access(DEFINES_REGISTER);
	access(DEFINES_REGISTER_FIELD);
	access(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2)); // Valid
	access(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,5)); // Invalid when not optimized

	return 0;
	
}