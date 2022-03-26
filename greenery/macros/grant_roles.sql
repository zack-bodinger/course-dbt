{% macro grant(role) %}

    {% set sql %}
      GRANT USAGE ON ALL SEQUENCES IN SCHEMA {{ schema }} TO GROUP {{ role }};
      GRANT SELECT ON {{ this }} TO GROUP {{ role }};
    {% endset %}

    {% set table = run_query(sql) %}

{% endmacro %}