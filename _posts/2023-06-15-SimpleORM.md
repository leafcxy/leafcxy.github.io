---
title: SimpleORM
date: 2023-06-15 15:16:40
tags:
---

<!-- more -->

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;

namespace SimpleORM
{
    public class ORM<T> where T : new()
    {
        private string connectionString;
        private string tableName;

        public ORM(string connectionString, string tableName)
        {
            this.connectionString = connectionString;
            this.tableName = tableName;
        }

        public List<T> SelectAll()
        {
            List<T> list = new List<T>();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string sql = $"SELECT * FROM {tableName}";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            T obj = new T();
                            PropertyInfo[] properties = typeof(T).GetProperties();
                            foreach (PropertyInfo property in properties)
                            {
                                property.SetValue(obj, reader[property.Name]);
                            }
                            list.Add(obj);
                        }
                    }
                }
            }
            return list;
        }

        public int Insert(T obj)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string sql = $"INSERT INTO {tableName} VALUES (";
                PropertyInfo[] properties = typeof(T).GetProperties();
                foreach (PropertyInfo property in properties)
                {
                    sql += $"@{property.Name},";
                }
                sql = sql.TrimEnd(',') + ")";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    foreach (PropertyInfo property in properties)
                    {
                        command.Parameters.AddWithValue($"@{property.Name}", property.GetValue(obj));
                    }
                    return command.ExecuteNonQuery();
                }
            }
        }

        public int Update(T obj)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string sql = $"UPDATE {tableName} SET ";
                PropertyInfo[] properties = typeof(T).GetProperties();
                foreach (PropertyInfo property in properties)
                {
                    sql += $"{property.Name}=@{property.Name},";
                }
                sql = sql.TrimEnd(',') + " WHERE Id=@Id";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    foreach (PropertyInfo property in properties)
                    {
                        command.Parameters.AddWithValue($"@{property.Name}", property.GetValue(obj));
                    }
                    return command.ExecuteNonQuery();
                }
            }
        }

        public int Delete(int id)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string sql = $"DELETE FROM {tableName} WHERE Id=@Id";
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@Id", id);
                    return command.ExecuteNonQuery();
                }
            }
        }
    }
}
```

```csharp
using System;
using System.Collections.Generic;
using System.Reflection;

namespace MyORM
{
    public class EntityMapper<TSource, TDestination> where TSource : class where TDestination : class, new()
    {
        private readonly Dictionary<string, PropertyInfo> _sourceProperties;
        private readonly Dictionary<string, PropertyInfo> _destinationProperties;

        public EntityMapper()
        {
            _sourceProperties = typeof(TSource).GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.GetProperty | BindingFlags.SetProperty);
            _destinationProperties = typeof(TDestination).GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.GetProperty | BindingFlags.SetProperty);
        }

        public TDestination Map(TSource source)
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }

            var destination = new TDestination();

            foreach (var sourceProperty in _sourceProperties)
            {
                if (_destinationProperties.TryGetValue(sourceProperty.Key, out var destinationProperty))
                {
                    destinationProperty.SetValue(destination, sourceProperty.Value.GetValue(source));
                }
            }

            return destination;
        }

        public IEnumerable<TDestination> Map(IEnumerable<TSource> source)
        {
            foreach (var item in source)
            {
                yield return Map(item);
            }
        }
    }
}
```
