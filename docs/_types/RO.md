---
title: RO
permalink: /engines/verilog/RO/
---
[{{page.title}}]: {{site.engine_baseurl}}/Verilog/Fields.pm


Read-Only Fields
================


```
RO [-verilog:retime [-verilog:clock CLOCK] [-verilog:reset RESET]]
   [-constant]

```

The [RO] type is a read-only status field.  The field value can be only
read by the bus and an error is generated if it is written to.


Example
-------


```
0W	1W	REG  {
	0b	4	Fh	FIELD_1	RW;
	4b	1	1	FIELD_2	RW -retime;
	5b	1	1	FIELD_3	RW -retime -clock custom;
};
```


```
module (
  output wire f_${identifer};
);
...

assign f_${identifier} = f_${identifier}_value;

always @(posedge ${bus_clock} or negedge ${bus_reset}) begin
  if (~${bus_reset}) begin
    f_${identifier}_value = ${value};
  end else begin
    f_${identifier}_value = ${identifer}_write_select 
end
```
