#include <stdio.h>
#include <sqlite3.h>

static int callback(void *data, int argc, char **argv, char **columns)
{
  int i;
  for (i = 0; i < argc; i++) {
    printf("%s = %s\n", columns[i], argv[i] ? argv[i] : "NULL");
  }
  return 0;
}

int main(int argc, char **argv)
{
  sqlite3* db;
  char *error;
  int exit;

  const char *query_create =
    "CREATE TABLE IF NOT EXISTS fruits ("
    "id          INT  PRIMARY KEY NOT NULL,"
    "fruit_name  TEXT             NOT NULL,"
    "fruit_color TEXT             NOT NULL)";


  const char *query_select = "SELECT * FROM fruits;";

  const char *query_insert =
    "INSERT OR REPLACE INTO fruits VALUES(1, 'Banana', 'Yellow');"
    "INSERT OR REPLACE INTO fruits VALUES(2, 'Apple', 'Green');"
    "INSERT OR REPLACE INTO fruits VALUES(3, 'Lemon', 'Yellow');"
    "INSERT OR REPLACE INTO fruits VALUES(4, 'Strawberry', 'Red');"
    "INSERT OR REPLACE INTO fruits VALUES(5, 'Watermelon', 'Green');"
    "INSERT OR REPLACE INTO fruits VALUES(6, 'Lime', 'Green');";

  const char *query_delete = "DELETE FROM fruits WHERE ID = 2;";

  /* Open the db file */
  exit = sqlite3_open("/tmp/fruits.db", &db);
  if (exit != SQLITE_OK) {
    fprintf(stderr, "OPEN - ERROR: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    return 1;
  }

  /* Create the table fruits */
  exit = sqlite3_exec(db, query_create, NULL, 0, &error);
  if (exit != SQLITE_OK) {
    fprintf(stderr, "CREATE TABLE - ERROR: %s\n", error);
    sqlite3_free(error);
    sqlite3_close(db);
    return 1;
  } else {
    printf("CREATE TABLE - SUCCESS\n");
  }

  /* Select all rows */
  printf("\n--- SELECT ---\n");
  sqlite3_exec(db, query_select, callback, NULL, NULL);
  printf("--------------\n\n");

  /* Populate the table */
  exit = sqlite3_exec(db, query_insert, NULL, 0, &error);
  if (exit != SQLITE_OK) {
    fprintf(stderr, "INSERT - ERROR: %s\n", error);
    sqlite3_free(error);
    sqlite3_close(db);
    return 1;
  } else {
    printf("INSERT - SUCCESS\n");
  }

  /* Select all rows */
  printf("\n--- SELECT ---\n");
  sqlite3_exec(db, query_select, callback, NULL, NULL);
  printf("--------------\n\n");


  /* Delete a row */
  exit = sqlite3_exec(db, query_delete, NULL, 0, &error);
  if (exit != SQLITE_OK) {
    fprintf(stderr, "DELETE - ERROR: %s\n", error);
    sqlite3_free(error);
    sqlite3_close(db);
    return 1;
  } else {
    printf("DELETE - SUCCESS\n");
  }

  /* Select all rows */
  printf("\n--- SELECT ---\n");
  sqlite3_exec(db, query_select, callback, NULL, NULL);
  printf("--------------\n\n");

  sqlite3_free(error);
  sqlite3_close(db);
  return 0;
}
