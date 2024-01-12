---
- name: Install new SSL certs on webservers
  hosts: all
  become: true


  vars_files:
    - vars/certificate.yml
  vars_prompt:
    - name: website
      prompt: Enter website name
      private: no

  tasks:
    
    - name: install SSL certificate
      copy:
        content: '{{ ssl_certificate }}'
        dest: /etc/pki/tls/certs/madgenius.com.crt
        owner: root
        group: root
        mode: 0644
        backup: yes

    - name: install SSL certificate CA
      copy:
        content: '{{ ssl_certificate_ca }}'
        dest: /etc/pki/tls/certs/intermediate.crt
        owner: root
        group: root
        mode: 0644
        backup: yes

    - name: Install private key
      copy:
        content: '{{ ssl_private_key }}'
        dest: /etc/pki/tls/private/madgenius.com.key
        owner: root
        group: root
        mode: 0600
        backup: yes
      no_log: true

    - name: restart apache
      service:
        name: httpd
        state: restarted

    - name: Check website status
      uri:
        url: https://'{{ website }}'
