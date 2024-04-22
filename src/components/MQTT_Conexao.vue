<template>
  <!-- Parte principal de como funciona as coisas na exibição -->

  <button type="success" size="small" class="conn-btn" style="margin-right: 20px;" :disabled="client.connected"
    @click="createConnection" :loading="connecting">
    <!-- mostrando o estado da conexao na tela -->
    <h1 class="Estado-conexão"> Estado da Conexão: {{ client.connected ? 'Conectado' : 'Conectar' }} </h1>

  </button>
  
 
  <!-- exibindo mensagens na tela -->
  <h2>{{ receiveNews }}</h2>
  <!-- Acima termina como funciona a exibição -->


</template>

<script>
import mqtt from "mqtt";

export default {
  // data é usado para definir quais objetos vao ser reativos no componente 
  data() {
    let host="mqtt-dashboard.com"
    // let host="mqtt-dashboard.com"
    return {
      // propriedades do objeto
      connection: {
        protocol: "wss",
        host,
        // ws: 8083; wss: 8084
        port: 8884,
        endpoint: "/mqtt",
        // for more options, please refer to https://github.com/mqttjs/MQTT.js#mqttclientstreambuilder-options
        clean: true,
        connectTimeout: 30 * 1000, // ms
        reconnectPeriod: 4000, // ms
        clientId: "clientId-PCRT0tbu2s" + Math.random().toString(16).substring(2, 8),
        // auth
        username: "Isaac",
        password: "Isaac",
      },
      // objeto subscription 
      subscription: {
        topic: "ssc/443/status",
        qos: 0,
      },
      publish: {
        topic: "testtopic/1",
        qos: 0,
        payload: '{ "msg": "Hello, I am browser." }',
      },
      receiveNews: "",
      qosList: [0, 1, 2],
      client: {
        connected: false,
      },
      subscribeSuccess: false,
      connecting: false,
      retryTimes: 0,
    };
  },
  // metodos que sao possiveis executar
  methods: {
    initData() {
      this.client = {
        // connected = propriedade
        connected: false,
      };
      this.retryTimes = 0;
      this.connecting = false;
      this.subscribeSuccess = false;
    },
    handleOnReConnect() {
      this.retryTimes += 1;
      if (this.retryTimes > 5) {
        try {
          this.client.end();
          this.initData();
          this.$message.error("Connection maxReconnectTimes limit, stop retry");
        } catch (error) {
          this.$message.error(error.toString());
        }
      }
    },
    createConnection() {
      try {
        this.connecting = true;
        const { protocol, host, port, endpoint, ...options } = this.connection;
        const connectUrl = `${protocol}://${host}:${port}${endpoint}`;
        this.client = mqtt.connect(connectUrl, options);
        if (this.client.on) {
          this.client.on("connect", () => {
            this.connecting = false;
            console.log("Conexão feita com sucesso!");
            this.doSubscribe(); // acionando metodo do subscribe 

            // exibe as mensagens 
            this.client.on("message", (topic, message) => {
              this.receiveNews = this.receiveNews.concat(message);
              console.log(`Mensagem Recebida: ${message} do topico: ${topic}`);
            });
          });
          this.client.on("reconnect", this.handleOnReConnect);
          this.client.on("error", (error) => {
            console.log("Connection failed", error);
          });

        }
      } catch (error) {
        this.connecting = false;
        console.log("mqtt.connect error", error);
      }
    },
    doSubscribe() {
      // extrai as propriedades topic e qos do objeto subscription 
      const { topic, qos } = this.subscription
      this.client.subscribe(topic, { qos }, (error, res) => {
        if (error) {
          console.log('Subscribe to topics error', error)
          return
        }
        this.subscribeSuccess = true
        console.log('Subscribe to topics res', res)
      })
    },
    // aqui termina o objeto methods 

    // daqui para baixo esses metodos nao estao funcionando pois falta colocar dentro da chave acima 
    doUnSubscribe() {
      const { topic } = this.subscription
      this.client.unsubscribe(topic, error => {
        if (error) {
          console.log('Unsubscribe error', error)
        }
      })
    },
    // metodo para publicar uma mensagem no broker
    doPublish() {
      const { topic, qos, payload } = this.publish
      this.client.publish(topic, payload, { qos }, error => {
        if (error) {
          console.log('Publish error', error)
        }
      })
    },
    // metodo para desfazer a conexão MQTT
    destroyConnection() {
      if (this.client.connected) {
        try {
          this.client.end(false, () => {
            this.initData()
            console.log('Successfully disconnected!')
          })
        } catch (error) {
          console.log('Disconnect failed', error.toString())
        }
      }
    }
  },
  // automaçao da conexao
  mounted(){
    this.createConnection();
  }
};
</script>
