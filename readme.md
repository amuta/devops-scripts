## Tarefas
Automatizar com scripts tarefas de sistema operacional ou de administração de serviços. Implemente a automatização das 3 tarefas abaixo usando a linguagem de scripting de sua preferência:

Tarefa 1 - criar e bloquear uma lista de 500 usuários alterando também duas propriedades do cadastro do usuário, por exemplo Nome e Cidade ou Diretório pessoal. Podem ser usados servidores Linux ou Windows para esta tarefa;

Tarefa 2 - criar um shellscript para automatizar a atribuição de grants em um sistema de banco de dados. Voce pode escolher o banco de dados de sua preferencia;

Tarefa 3- Instalar um sistema de VPN e criar um script de login automático no servidor e em um login por ssh;

## Como usar
Detalhe: tornar os arquivos como executáveis (chmod +x) antes de usar

A tarefa 1 está contemplada no script multiusers.sh, para ver como utilizar ele executa ./multusers.sh -h (chmod +x multusers.sh caso o arquivo não esteja como executável) exemplo: > ./multusers.sh -a -l -f newusers.txt -d /home/empregados -i "Temporario" * Esse comando ira criar todos os usuarios no arquivo newusers.txt com o diretorio pessoal sendo /home/empregados e o nome Temporario.

A tarefa 2 está contemplada no script grants.sh e para ver suas funcionalidades é só fazer como acima, ./grants.sh -h para ver os exemplos.

Por fim a tarefa 3 é dividida em 2 partes, a primeira é o servidor VPN, o qual é no caso um servidor OpenVPN rodando em uma instância Ubuntu no EC2 da Amazon e um script para realizar as conexões da maquina local.

O servidor foi configura seguindo esse [tutorial](https://www.cyberciti.biz/faq/howto-setup-openvpn-server-on-ubuntu-linux-14-04-or-16-04-lts/)
O IP que eu coloquei no script do servidor é do ElasticIP do AWS, então pelo menos nos proximos dias eu devo deixar ele aberto para o teste do script.
