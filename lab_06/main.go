package main

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var MENU_INFO = "\nМЕНЮ:\n" + 
          "1. Выполнить скалярный запрос\n" + 
          "2. Выполнить запрос с несколькими соединениями (JOIN)\n" + 
          "3. Выполнить запрос с ОТВ(CTE) и оконными функциями\n" + 
          "4. Выполнить запрос к метаданными\n" + 
          "5. Вызвать скалярную функцию\n" + 
          "6. Вызвать табличную функцию\n" + 
          "7. Вызвать хранимую процедуру\n" + 
          "8. Вызвать системную функцию\n" + 
          "9. Создать таблицу в базе данных, соответствующую тематике БД\n" + 
          "10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY\n" + 
          "0. Выход\n" + 
          "Выбор: "

var EXIT = 0
var SCALAR_QUERY = 1
var MULTIPLE_JOIN = 2
var CTE_WINDOW_FUNC = 3
var META_QUERY = 4
var SCALAR_FUNC = 5
var TABLE_FUNC = 6
var STORED_PROC = 7
var SYSTEM_FUNC = 8
var CREATE_TABLE = 9
var INSERT_INTO_TABLE = 10

func main() {
	db, err := sqlx.Connect("postgres", "host=localhost user=postgres password=postgres port=8080 sslmode=disable")
    if err != nil {
        fmt.Println(err)
		return
    }

	dataBase := initDB(db)

	var choice int 
	fmt.Println(MENU_INFO)
	_, err = fmt.Scan(&choice) 
	if err != nil {
		fmt.Println(err)
		return
	}
	for choice != EXIT {
		switch choice {
		case SCALAR_QUERY:
			err := dataBase.scalarQuery()
			if err != nil {
				fmt.Println(err)
				return
			}
		case MULTIPLE_JOIN:
			err := dataBase.multipleJoin()
			if err != nil {
				fmt.Println(err)
				return
			}
		case CTE_WINDOW_FUNC:
			err := dataBase.cteWindowFunc()
			if err != nil {
				fmt.Println(err)
				return
			}
		case META_QUERY:
			err := dataBase.metaQuery()
			if err != nil {
				fmt.Println(err)
				return
			}
		case SCALAR_FUNC:
			err := dataBase.scalarFunc()
			if err != nil {
				fmt.Println(err)
				return
			}
		case TABLE_FUNC:
			err := dataBase.tableFunc()
			if err != nil {
				fmt.Println(err)
				return
			}
		case STORED_PROC:
			err := dataBase.storedProc()
			if err != nil {
				fmt.Println(err)
				return
			}
		case SYSTEM_FUNC:
			err := dataBase.systemFunc()
			if err != nil {
				fmt.Println(err)
				return
			}
		case CREATE_TABLE:
			err := dataBase.createTable()
			if err != nil {
				fmt.Println(err)
				return
			}
		case INSERT_INTO_TABLE:
			err := dataBase.insertIntoTable()
			if err != nil {
				fmt.Println(err)
				return
			}
		default:
			fmt.Println("Incorrect choice!")
			return
		}

		fmt.Println(MENU_INFO)
		_, err := fmt.Scan(&choice)
		if err != nil {
			fmt.Println(err)
			return
		}
	}

}