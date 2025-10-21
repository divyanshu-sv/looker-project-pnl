# The name of this view in Looker is "Department Dimension"
view: department_dimension {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `Profit_and_Loss_Dataset.Department_Dimension` ;;
  drill_fields: [dept_id]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: dept_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.dept_id ;;
  }
    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Department Name" in Explore.

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.manager_name ;;
  }
  measure: count {
    type: count
    drill_fields: [dept_id, manager_name, department_name]
  }
}
