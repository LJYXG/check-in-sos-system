#!/bin/bash
#Edit by ZJHCOFI
#���ܣ������ض���������ʼ�
#����©���޲�(����)ͨ��ҳ�棺https://space.bilibili.com/9704701/dynamic
#2021-12-12 21:31

##########�ɱ༭��#############
#     ���޸� "" �ڵ�����      #

#-----�û���Ϣ
# ǩ�����û���
user_name="admin"
# �ʼ����ͼ�¼����·��
send_mail_log="/usr/www/send_mail.log"

#-----���һ
# ����δǩ������ִ�У���ע��������һ���������������������������ǰ��ÿ��ִ�У�
Attention_day="1"
# �ʼ�����
Attention_title="ǩ����ʾ"
# �ʼ����ģ�������ʹ��"\n"��
Attention_text="��ǩ������\n�ٲ�ǩ�������˽���Զ�����ȥ�ˣ�"
# �ʼ�����·����û�и��������գ�
Attention_appendix=""
# �ʼ��ռ��ˣ�����ռ�������Ӣ�Ķ���","�ָ
Attention_addressee="test@qq.com"

#-----�����
# ����δǩ������ִ�У���ֻ�ڷ��������ĵ���ִ�У�
Warning_day="3"
# �ʼ�����
Warning_title="ZJH�����������⣬�뾡����ϵ��"
# �ʼ����ģ�������ʹ��"\n"��
Warning_text="ZJH�����������⣬�뾡����ϵ��\n�����ֻ��ţ�12345\n�����׵��ֻ��ţ�12345\n��ĸ�׵��ֻ��ţ�12345\n\n���ʼ���ǩ��ϵͳ�Զ����������Ѿ�${Warning_day}��ûǩ����"
# �ʼ�����·����û�и��������գ�
Warning_appendix=""
# �ʼ��ռ��ˣ�����ռ�������Ӣ�Ķ���","�ָ
Warning_addressee="test@qq.com,test@163.com"

#-----�����
# ����δǩ������ִ�У���ֻ�ڷ��������ĵ���ִ�У�
Error_day="7"
# �ʼ�����
Error_title="������Ʒһ����"
# �ʼ����ģ�������ʹ��"\n"��
Error_text="������յ����ʼ����뽫���ʼ���������XXX��\n���˸����˺�����������ڸ����ڣ��ø����Ѽ��ܣ�ֻ��XXX֪�����룩\n\n���ʼ���ǩ��ϵͳ�Զ����������Ѿ�${Error_day}��ûǩ����"
# �ʼ�����·����û�и��������գ�
Error_appendix="/usr/www/ZJH_something.zip"
# �ʼ��ռ��ˣ�����ռ�������Ӣ�Ķ���","�ָ
Error_addressee="test@qq.com,test@163.com"

#-----���ݿ���Ϣ
# mysql���ݿ��û���
mysql_user="root"

# mysql���ݿ�����
mysql_passwd="Bili@233"

# mysql���ݿ�˿ڣ�Ĭ��Ϊ3306��
mysql_port="3306"

#########�ɱ༭������#########

#-----------------------------
#-------���´�������--------
#-----------------------------

# ��ǰʱ��
send_time=$(date "+%Y-%m-%d %H:%M:%S")

# ������ݿ�����
mysql -P${mysql_port} -u${mysql_user} -p${mysql_passwd} ciss_db -e "select count(*) from ciss_user where user_name='${user_name}'" > sql.temp	
mysql_check=`tail -n 1 sql.temp`
mysql_printf_check=`echo -n "${mysql_check}" | tr -d '^[0-9]+$'`

# ������ݿ������쳣
if [[ "${mysql_check}" == "" || "${mysql_printf_check}" != "" ]];then

  echo -e "\n���������ݿ����ӻ��߲�ѯ�������⣬���飺\n1���ɱ༭�������ݿ���Ϣ�Ƿ���ȷ\n2���Ƿ���ʹ��rootȨ��ִ�б��ű�\n3���Ƿ�����������sql�ļ�\n"
  exit

else

  # ������ݿ��������������û���������
  if [[ "${mysql_check}" == "0" ]];then
    
    echo -e "\n�������û��������ڣ����޸ģ�\n"
    exit
    
  else
    # δǩ����������ѯ
    no_check_days=`mysql -P${mysql_port} -u${mysql_user} -p${mysql_passwd} ciss_db -e "SELECT datediff(DATE_FORMAT(now(),'%Y-%m-%d'),DATE_FORMAT(c.check_time,'%Y-%m-%d')) FROM ciss_user u left join ciss_check_in c on u.user_id = c.check_user_id where u.user_name = '${user_name}' order by c.check_time desc limit 1" | grep -v check`
    # ���û��ǩ����¼
    if [[ "${no_check_days}" == "" || "${no_check_days}" == "NULL" ]];then
    	echo -e "${send_time}\t��ǩ����¼" >> ${send_mail_log}
    	exit
    fi
    # ��������һ
    if [[ "${no_check_days}" -ge "${Attention_day}" && "${no_check_days}" -lt "${Warning_day}" ]];then
      if [[ "${Attention_appendix}" != "" ]];then
        echo -e "${Attention_text}" | mailx -s "${Attention_title}" -a ${Attention_appendix} ${Attention_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Attention_title}\t${Attention_text}\t${Attention_addressee}\t${Attention_appendix}" >> ${send_mail_log}
      else
        echo -e "${Attention_text}" | mailx -s "${Attention_title}" ${Attention_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Attention_title}\t${Attention_text}\t${Attention_addressee}" >> ${send_mail_log}
      fi
    fi
    # ����������
    if [[ "${no_check_days}" == "${Warning_day}" ]];then
      if [[ "${Warning_appendix}" != "" ]];then
        echo -e "${Warning_text}" | mailx -s "${Warning_title}" -a ${Warning_appendix} ${Warning_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Warning_title}\t${Warning_text}\t${Warning_addressee}\t${Warning_appendix}" >> ${send_mail_log}
      else
        echo -e "${Warning_text}" | mailx -s "${Warning_title}" ${Warning_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Warning_title}\t${Warning_text}\t${Warning_addressee}" >> ${send_mail_log}
      fi
    fi
    # ����������
    if [[ "${no_check_days}" == "${Error_day}" ]];then
      if [[ "${Error_appendix}" != "" ]];then
        echo -e "${Error_text}" | mailx -s "${Error_title}" -a ${Error_appendix} ${Error_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Error_title}\t${Error_text}\t${Error_addressee}\t${Error_appendix}" >> ${send_mail_log}
      else
        echo -e "${Error_text}" | mailx -s "${Error_title}" ${Error_addressee}
        echo -e "���ͼ�¼��\t${send_time}\t${Error_title}\t${Error_text}\t${Error_addressee}" >> ${send_mail_log}
      fi
    fi  
  
  fi

fi