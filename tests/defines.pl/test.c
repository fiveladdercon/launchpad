#include <stdio.h>
#include "test.h"

void access(fields) {

	printf("=============================================\n");
	printf("access_of  = %d\n", access_of(field)  );
	printf("size_of    = %d\n", size_of(field)    );
	printf("address_of = %d\n", address_of(field) );
	printf("is_valid   = %d\n", is_valid(field)   );
	printf("name_of    = %s\n", name_of(field)    );
	printf("value_of   = %s\n", value_of(field)   );

}

int main () {

	// Direct use of defines

	printf("---------------------------------------------\n");
	printf("access_of  = %d\n", access_of(DEFINES_FIELD)  );
	printf("size_of    = %d\n", size_of(DEFINES_FIELD)    );
	printf("address_of = %d\n", address_of(DEFINES_FIELD) );
	printf("is_valid   = %d\n", is_valid(DEFINES_FIELD)   );
	printf("name_of    = %s\n", name_of(DEFINES_FIELD)    );
	printf("value_of   = %s\n", value_of(DEFINES_FIELD)   );

	printf("---------------------------------------------\n");
	printf("access_of  = %d\n", access_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))  );
	printf("size_of    = %d\n", size_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))    );
	printf("address_of = %d\n", address_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2)) );
	printf("is_valid   = %d\n", is_valid(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))   );
	printf("name_of    = %s\n", name_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))    );
	printf("value_of   = %s\n", value_of(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2))   );

	// Indirect use of defines

	access(DEFINES_FIELD);
	access(DEFINES_REGISTER);
	access(DEFINES_REGISTER_FIELD);
	access(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,2)); // Valid
	access(DEFINES_ARRAY_x_FIELD_i_x_y(2,1,1,5)); // Invalid

	return 0;
	
}