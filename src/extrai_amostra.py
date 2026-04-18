import os
print("CWD:", os.getcwd())
print("Dir atual:", os.listdir(os.getcwd()))
import sys
print(sys.path)
import pandas as pd
df = pd.read_excel(r'D:\IC-Tweets\Recursos\Amostras\copia_tweets_bolsonaro.xlsx')
amostra = df.iloc[20:30].reset_index(drop=True)
print(f'Amostra com {len(amostra)} tweets.')
amostra.to_csv('amostra_10.csv', index=False, encoding='utf-8')