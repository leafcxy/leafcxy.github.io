---
title: xml与对象相互转换
date: 2023-08-03 10:07:48
tags:
---

<!-- more -->

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.IO;
using System.Xml;
using System.Text.RegularExpressions;

namespace Helper
{
    public class XmlSerializeHelper
    {

        public static string Serialize<T>(T obj)
        {
            return Serialize<T>(obj, Encoding.UTF8);
        }

        //对象转XML
        public static string ObjToXml(object obj)
        {
            using (MemoryStream Stream = new MemoryStream())
            {
                XmlSerializer xml = new XmlSerializer(obj.GetType());
                xml.Serialize(Stream, obj);
                Stream.Position = 0;
                StreamReader sr = new StreamReader(Stream);
                string str = sr.ReadToEnd();
                return str;
            }

        }

        /// <summary>  
        /// 实体对象序列化成xml字符串  
        /// </summary>  
        /// <typeparam name="T"></typeparam>  
        /// <param name="obj"></param>  
        /// <returns></returns>  
        public static string Serialize<T>(T obj, Encoding encoding)
        {
            try
            {

                if (obj == null)
                    throw new ArgumentNullException("obj");

                var ser = new XmlSerializer(obj.GetType());
                using (var ms = new MemoryStream())
                {
                    using (var writer = new XmlTextWriter(ms, encoding))
                    {
                        writer.Formatting = Formatting.Indented;
                        ser.Serialize(writer, obj);
                    }
                    var xml = encoding.GetString(ms.ToArray());
                    xml = xml.Replace("xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"", "");
                    xml = xml.Replace("xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"", "");
                    xml=Regex.Replace(xml,@"\s{2}","");
                    xml = Regex.Replace(xml, @"\s{1}/>", "/>");
                    return xml;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>  
        /// 反序列化xml字符为对象，默认为Utf-8编码  
        /// </summary>  
        /// <typeparam name="T"></typeparam>  
        /// <param name="xml"></param>  
        /// <returns></returns>  
        public static T DeSerialize<T>(string xml)
            where T : new()
        {
            return DeSerialize<T>(xml, Encoding.UTF8);
        }

        /// <summary>  
        /// 反序列化xml字符为对象  
        /// </summary>  
        /// <typeparam name="T"></typeparam>  
        /// <param name="xml"></param>  
        /// <param name="encoding"></param>  
        /// <returns></returns>  
        public static T DeSerialize<T>(string xml, Encoding encoding)
            where T : new()
        {
            try
            {
                var mySerializer = new XmlSerializer(typeof(T));
                using (var ms = new MemoryStream(encoding.GetBytes(xml)))
                {
                    using (var sr = new StreamReader(ms, encoding))
                    {
                        return (T)mySerializer.Deserialize(sr);
                    }
                }
            }
            catch (Exception e)
            {
                return default(T);
            }

        }  
    }
}
```
