#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
TIME_STAMP=$(date "+%Y-%m-%d %H:%M:%S")

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$TIME_STAMP [ERROR] $R Please run this script with root user $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIME_STAMP [ERROR] $2 ....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else    
        echo -e "$TIME_STAMP [INFO] $2 ....$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo Repo"

dnf install mongodb-org -y & >> $LOGS_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable --now mongod
VALIDATE $? "Starting and enabling MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"



