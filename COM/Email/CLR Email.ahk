C# := LoadC#() ;CSharp code to compile
attachs = %A_ScriptFullPath%|%A_ScriptDir%\Test.htm ;Pipe delimited list of attachment files

CLR_StartDomain( mailDomain ) ;Isolate code to new AppDomain
if not ( asm := CLR_CompileC#(C#, "System.dll|System.Windows.Forms.dll", mailDomain ) ) ;Compile in memory
  {
  MsgBox, 48, Error!, Could not compile C#
  ExitApp
  }

mail := CLR_CreateObject(asm, "iMail") ;Create object instance

sent := mail.iSend("smtp.gmail.com"          ;smtp server
                  , 587                      ;port
                  , "drshajul@gmail.com"     ;username
                  , "pr0minent"              ;password
                  , "drshajul@gmail.com"     ;from address
                  , "drresmysusan@gmail.com" ;to address
                  , "Hi dear just testing my script" ;message body
                  , "Hello dear"             ;message subject
                  , attachs                  ;attachments
                  , True)                    ;ssl enabled
if not sent
  MsgBox, 48, Error!, Message sending failed!

CLR_StopDomain( mailDomain ) 

LoadC#() {
c# =
(
using System;
using System.Net;
using System.Net.Mail;
using System.Windows.Forms;
 
public class iMail
{
  public bool iSend(string host, int port, string userName, string pswd, string fromAddress, string toAddress, string body, string subject, string attachments, bool sslEnabled) 
  {
   try
    {
      MailMessage msg = new MailMessage(new MailAddress(fromAddress), new MailAddress(toAddress));
      msg.Subject = subject;
      msg.SubjectEncoding = System.Text.Encoding.UTF8;
      msg.Body = body;
      msg.BodyEncoding = System.Text.Encoding.UTF8;
      msg.IsBodyHtml = false;
      
      SmtpClient client = new SmtpClient(host, port);
      client.Credentials = new NetworkCredential(userName, pswd);
      client.EnableSsl = sslEnabled;
      if (attachments.Length != 0)
         {
         string[] arrAttach = attachments.Split('|');
         if (arrAttach != null && arrAttach.Length > 0)
             foreach(string Attachment in arrAttach)
                 msg.Attachments.Add(new System.Net.Mail.Attachment(Attachment));
         }
      client.Send(msg);
    }
    catch (Exception ex)
    {
      MessageBox.Show(ex.ToString());
      return false;
    }
   return true;
  }
}
)
return c#
}