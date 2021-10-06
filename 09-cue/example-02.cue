output: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	spec: {
		selector: matchLabels: {
			"app.oam.dev/component": "test"
			app:                     "test"
		}
		template: {
			metadata: labels: {
				"app.oam.dev/component": "test"
				app:                     "test"
			}
			spec: containers: [{
				name:  "test"
				image: "test"
				command: [
					"nginx",
				]
				ports: [{
					containerPort: 80
				}]
			}]
		}
	}
}
parameter: {
	image: "test"
	cmd: [
		"nginx",
	]
	port: 80
}
context: name: "test"
