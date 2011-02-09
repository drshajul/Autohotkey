asm := CLR_CompileC#(LoadC#(), "System.dll|System.Windows.Forms.dll",,"MyMail.dll","/target:library")
ExitApp

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