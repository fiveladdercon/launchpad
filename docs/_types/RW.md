---
title: RW
permalink: /engines/verilog/RW/
---
[{{page.title}}]: {{site.engine_baseurl}}/Verilog/Fields.pm


RW Fields
=========


```
RW [-verilog:retime [-verilog:clock CLOCK] [-verilog:reset RESET]]

```

The [RW] type is a read/write control field.  The field value can be
written and read by the bus.

If the `-verilog:retime` property is present, the field value is dual rank
resynchronized before it leaves the module.







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
