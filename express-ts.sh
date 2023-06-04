#!/bin/bash

projectName="server"

rm -rf $projectName       

mkdir $projectName

cd $projectName

npm install -g yarn

npm init -y

yarn add express cors dotenv
yarn add -D typescript ts-node @types/node @types/express @types/cors nodemon

npx tsc --init

mkdir -p src/{router,service,middleware,models,controller}
mkdir -p src/{controller,service}/user

echo "PORT=8000" > .env

echo "import express, { Request, Response } from 'express'
import userRouter from './router/user'
import dotenv from 'dotenv'
import cors from 'cors'

dotenv.config();

const port = process.env.PORT;

const app = express();
app.use(cors())
app.use(express.json())

app.use('/user', userRouter)

app.get('/', (req: Request, res: Response) => {
    res.send('Hello, World!');
});

app.listen(port, () => {
    console.log(\`Server is running on port \${port}\`);
});
" > src/index.ts

echo "
import { Router } from 'express';
import { userController } from '../controller/user/user.controller';

const userRouter = Router();

userRouter.get('/', userController);

export default userRouter
" > src/router/user.ts

echo "
import { Request, Response } from 'express';
import { userService } from '../../service/user/user.service';

export const userController = async (req: Request, res: Response) => {
    try {
        const address = req.body.address;
        const userResponse = await userService(address);
        res.json(userResponse);
    }
    catch (err) {
        res.status(400).json({ err: (err as Error).message });
    }
}
" > src/controller/user/user.controller.ts


echo "export const userService = async (address: string) => {
  return { output: \"Test\" }
}
" > src/service/user/user.service.ts

echo '{
  "compilerOptions": {
    "outDir": "./dist",
    "target": "es2016",
    "module": "commonjs",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true
  }
}' > tsconfig.json

node -e "let pkg=require('./package.json'); pkg.scripts.start='ts-node ./src/index.ts'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"
node -e "let pkg=require('./package.json'); pkg.scripts.dev='nodemon --exec ts-node ./src/index.ts'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"
node -e "let pkg=require('./package.json'); pkg.scripts.build='rm -rf dist && tsc'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"
