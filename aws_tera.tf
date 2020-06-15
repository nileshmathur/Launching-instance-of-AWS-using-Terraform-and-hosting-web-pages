provider "aws"{
   region="ap-south-1"                                                      #Specifying AWS as a provider
   profile="nileshmathur"
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_instance" "webos"{
  ami="ami-0447a12f28fddb066"                                             #Launching an instance
  instance_type="t2.micro"
  key_name="firstkey"
  security_groups=["launch-wizard-2"]

  connection{
        type="ssh"
        user="ec2-user"
        private_key=file("C:/Users/DELL/Downloads/"newkey.ppk")
        host=aws_instance.webos.public_ip
  }
   
   provisioner "remote-exec"{                                              #Installing php,git and http web server and starting the services
     inline=[
             "sudo yum install httpd php git -y",
             "sudo systemctl start httpd",
             "sudo systemctl enable httpd",
           ]
   }

  tags={
       Name="osformtera"
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_ebs_volume" "ebs1" {
  availability_zone=aws_instance.webos.availability_zone                       #Adding volume to an instance
  size=1
  tags={
      Name="osvol"
   }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////

resource "aws_volume_attachment" "ebs_att"{                                  #Attaching volume to the instance
   device_name="/dev/sdh"
   volume_id= aws_ebs_volume.ebs1.id
   instance_id=aws_instance.webos.id
   force_detach=true
}
////////////////////////////////////////////////////////////////////////////////////////////////////


output "myoutput_ip"{
    value=aws_instance.webos.public_ip                                       #Printing IP Address on the command line
}
//////////////////////////////////////////////////////////////////////////////////////////////////////// 


resource "null_resource" "nulllocal"{
  provisioner "local-exec"{
      command="echo ${aws_instance.webos.public_ip} > publicip.txt"           #Creating a file that contains IP Address of instance
   }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////   
   

resource "null_resource" "nullremote"{
   depends_on=[
          aws_volume_attachment.ebs_att,                #Marking dependency of formatting and mounting of volume to the attachment of it
    ]
    
    connection{
        type="ssh"
        user="ec2-user"
        private_key=file("C:/Users/DELL/Downloads/firstkey.ppk")
        host=aws_instance.webos.public_ip
    }
    
    provisioner "remote-exec" {
         inline=[
                 "sudo mkfs.ext4 /dev/xvdh",
                 "sudo mount /dev/xvdh  /var/www/html",
                 "sudo rm -rf /var/www/html/*",
                  "sudo git clone https://github.com/nileshmathur/Launching-instance-of-AWS-using-Terraform-and-hosting-web-pages     /var/www/html/"
                 ]
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                     
        
resource "null_resource" "nulllocal1"{
    
     depends_on=[
            null_resource.nullremote,
     ]
    
     provisioner "local-exec" {
           command ="chrome ${aws_instance.webos.public_ip}"
     }


}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#This is my Terraform code





