import numpy as np
import pandas as pd

# ------------------------------------------------------------------------------------------------------------------------------------
# Importing data
games_data = pd.read_csv(r"Projects\full_ML_projects\steam_games_recommendations_system\data\steam_games_data\games.csv")
recommendations_data = pd.read_csv(r"Projects\full_ML_projects\steam_games_recommendations_system\data\steam_games_data\recommendations.csv")

print(games_data.shape)
print(recommendations_data.shape)


print(list(games_data.columns) , end="\n\n\n")
print(list(recommendations_data.columns) , end="\n\n\n")


game_playing_hours = recommendations_data.groupby("app_id")[["hours"]].sum()
game_reco_num = recommendations_data.groupby('app_id')[["is_recommended"]].sum()

print(game_playing_hours , end="\n\n")
print(game_playing_hours.shape , end="\n\n")
print(list(game_playing_hours.columns) , end="\n\n" )


print(game_reco_num , end="\n\n")
print(game_reco_num.shape , end="\n\n")
print(list(game_reco_num.columns) , end="\n\n" )


games_data = pd.merge(games_data , game_playing_hours , how="left" , on="app_id")
games_data = pd.merge(games_data , game_reco_num , how="left" , on="app_id")

print(games_data.shape, end="\n\n\n")

print(list(games_data.columns) , end="\n\n\n")

print(games_data.isnull().sum() , end="\n\n\n")

print(games_data.sample(5) , end="\n\n")

games_data.to_csv(r"D:\AI\Projects\full_ML_projects\steam_games_recommendations_system\data\steam_games_data\games_final_data.csv")

