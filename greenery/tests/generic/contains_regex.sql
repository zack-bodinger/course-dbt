{% test contains_regex(model, column_name, regex) %}


   select *
   from {{ model }}
   where {{ column_name }} !~  '{{ regex }}'


{% endtest %}