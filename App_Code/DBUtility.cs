using System;
using System.Configuration;
using System.Collections.Generic;
using System.Data.Odbc;

/// <summary>
/// Summary description for DBUtility
/// </summary>
public class DBUtility
{
    public DBUtility()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static Dictionary<int, Dictionary<string, string>> SqlRead(string query, string data)
    {
        OdbcConnection connection = new OdbcConnection();
        connection = conn();

        using (connection)
        {
            try
            {
                Dictionary<int, Dictionary<string, string>> resp = new Dictionary<int, Dictionary<string, string>>();
                OdbcCommand cmd = new OdbcCommand();
                cmd.CommandType = System.Data.CommandType.Text;
                cmd.CommandText = query;
                cmd.Connection = connection;
                connection.Open();
                OdbcDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    // get field data
                    int rowCt = 0;
                    while (reader.Read())
                    {
                        Dictionary<string, string> item = new Dictionary<string, string>();
                        for (int j = 0; j < reader.FieldCount; j++)
                        {
                            string colName = reader.GetName(j);
                            string colVal = "";
                            if (reader.IsDBNull(j))
                            {
                                colVal = "";
                            }
                            else
                            {
                                colVal = reader[j].ToString();
                            }
                            item.Add(colName, colVal);
                        }
                        resp.Add(rowCt, item);
                        rowCt++;
                    }
                }
                connection.Close();
                return resp;
            }
            catch (Exception e)
            {
                return null;
            }
        }
    }

    public static string ExecuteSql(string query, string data)
    {
        string resp = "";
        OdbcConnection connection = new OdbcConnection();
        connection = conn();

        using (connection)
        {
            try
            {
                OdbcCommand cmd = new OdbcCommand();
                cmd.CommandType = System.Data.CommandType.Text;
                cmd.CommandText = query;
                cmd.Connection = connection;
                connection.Open();
                cmd.ExecuteNonQuery();
                connection.Close();
                resp = "OK";
            }
            catch (Exception e)
            {
                resp = "X";
            }
        }
        return resp;
    }

    public static string ExecuteScalar(string query, string data)
    {
        string resp = "";
        OdbcConnection connection = new OdbcConnection();
        connection = conn();

        using (connection)
        {
            try
            {
                OdbcCommand cmd = new OdbcCommand();
                cmd.CommandType = System.Data.CommandType.Text;
                cmd.CommandText = query;
                cmd.Connection = connection;
                connection.Open();
                resp = Convert.ToString(cmd.ExecuteScalar());
                connection.Close();
            }
            catch (Exception e)
            {
                resp = "X";
            }
        }
        return resp;
    }

    private static OdbcConnection conn()
    {
        OdbcConnection myConn = new OdbcConnection();
        myConn.ConnectionString = ConfigurationManager.ConnectionStrings["FFAConn"].ConnectionString;
        return myConn;
    }
}