network policies: 
    who can talk to whom
    Controls who can communicate with whom inside the cluster.
![image](https://github.com/user-attachments/assets/e26d47f1-6ed8-4f18-abd3-cc48db7c05db)





    egress:
    whom can i talk to

    pod selector:
    app: hello

    ingress:
        -from:
            app:foo 
                means the foo can only talk to hello (anythg else try wont work)

        after getting into container execute the wget =wont work

        ![image](https://github.com/user-attachments/assets/0c573a6d-1fd7-4556-9baf-d80908dfc180)
